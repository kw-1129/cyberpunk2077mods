// Independent Basilisk system; can coexist with the current HGTankSystem.
public class HGBasiliskSystem extends ScriptableSystem {
  private let entityID: EntityID;
  private let initialized: Bool;
  private let pending: Bool;
  private let pendingTime: Float;
  private let message: String;

  public static func Get() -> ref<HGBasiliskSystem> {
    return GameInstance.GetScriptableSystemsContainer(GetGameInstance()).Get(n"HGBasiliskSystem") as HGBasiliskSystem;
  }

  public func Tank() -> ref<VehicleObject> {
    return GameInstance.FindEntityByID(this.GetGameInstance(),this.entityID) as VehicleObject;
  }

  public func Message() -> String { return HGBText.Text(this.message); }

  public func Gameplay() -> Bool {
    let p = GetPlayer(this.GetGameInstance());
    if !IsDefined(p) || p.IsDead() || GameInstance.GetSystemRequestsHandler().IsPreGame() { return false; }
    return !GameInstance.GetBlackboardSystem(p.GetGame()).Get(GetAllBlackboardDefs().UI_System).GetBool(GetAllBlackboardDefs().UI_System.IsInMenu)
      && !GameInstance.GetPhotoModeSystem(p.GetGame()).IsPhotoModeActive();
  }

  public func RegisterGarage() -> Void {
    GameInstance.GetVehicleSystem(this.GetGameInstance()).EnablePlayerVehicleID(t"Vehicle.HG_Basilisk",true);
    this.message = "Basilisk registered in the vehicle call list.";
  }

  public func RemoveGarage() -> Bool {
    if !this.Recall() { return false; }
    GameInstance.GetVehicleSystem(this.GetGameInstance()).EnablePlayerVehicleID(t"Vehicle.HG_Basilisk",false);
    this.initialized = true;
    this.message = "Garage entry removed.";
    return true;
  }

  public func Recall() -> Bool {
    let tank = this.Tank();
    if IsDefined(tank) && tank.IsPlayerMounted() { this.message = "Exit the Basilisk before recall."; return false; }
    if EntityID.IsDefined(this.entityID) { GameInstance.GetDynamicEntitySystem().DeleteEntity(this.entityID); }
    this.entityID = EntityID();
    this.pending = false;
    this.message = "Basilisk recalled.";
    return true;
  }

  public func Deploy() -> Bool {
    if !this.Gameplay() { this.message = "Load a save and return to gameplay first."; return false; }
    if this.pending { this.message = "Deployment in progress."; return false; }
    let p = GetPlayer(this.GetGameInstance());
    if VehicleComponent.IsMountedToVehicle(p.GetGame(),p.GetEntityID()) { this.message = "Exit the current vehicle first."; return false; }
    if PlayerPuppet.GetSceneTier(p) > 2 { this.message = "Finish the current scene first."; return false; }
    if IsEntityInInteriorArea(p) { this.message = "Deploy on open outdoor ground."; return false; }
    let position = p.GetWorldPosition() + p.GetWorldForward() * 22.0;
    let hit: TraceResult;
    if !GameInstance.GetSpatialQueriesSystem(p.GetGame()).SyncRaycastByCollisionGroup(position + Vector4(0.0,0.0,8.0,0.0),position - Vector4(0.0,0.0,30.0,0.0),n"Static",hit,false,false) {
      this.message = "No ground ahead. Face a clear level surface.";
      return false;
    }
    position = Cast<Vector4>(hit.position);
    position.Z += 0.5;
    if !this.Recall() { return false; }
    let spec = new DynamicEntitySpec();
    spec.recordID = t"Vehicle.HG_Basilisk";
    spec.position = position;
    spec.orientation = p.GetWorldOrientation();
    spec.persistState = false;
    spec.persistSpawn = false;
    spec.alwaysSpawned = true;
    spec.tags = [n"HGBasilisk"];
    this.entityID = GameInstance.GetDynamicEntitySystem().CreateEntity(spec);
    this.pending = EntityID.IsDefined(this.entityID);
    this.pendingTime = 0.0;
    this.message = this.pending ? "Deploying Basilisk..." : "Spawn request failed.";
    return this.pending;
  }

  public func Board() -> Bool {
    if !this.Gameplay() { return false; }
    let tank = this.Tank();
    let p = GetPlayer(this.GetGameInstance());
    if !IsDefined(tank) || !tank.IsAttached() || tank.IsDestroyed() || this.pending { this.message = "Deploy a working Basilisk first."; return false; }
    if VehicleComponent.IsMountedToVehicle(p.GetGame(),p.GetEntityID()) { return false; }
    if Vector4.Distance(p.GetWorldPosition(),tank.GetWorldPosition()) > 35.0 { this.message = "Move within 35 m of the Basilisk."; return false; }
    let request = new MountingRequest();
    request.lowLevelMountingInfo.childId = p.GetEntityID();
    request.lowLevelMountingInfo.parentId = tank.GetEntityID();
    request.lowLevelMountingInfo.slotId.id = n"seat_front_left";
    request.mountData = new MountEventData();
    request.mountData.isInstant = true;
    GameInstance.GetMountingFacility(p.GetGame()).Mount(request);
    this.message = "Boarding the driver seat.";
    return true;
  }

  public func Tick(delta: Float,autoRegister: Bool) -> Void {
    if !IsDefined(GetPlayer(this.GetGameInstance())) || GameInstance.GetSystemRequestsHandler().IsPreGame() { return; }
    if !this.initialized { if autoRegister { this.RegisterGarage(); } this.initialized = true; }
    if !this.pending { return; }
    let tank = this.Tank();
    if IsDefined(tank) && tank.IsAttached() {
      let controller = tank.GetAccessoryController();
      if IsDefined(controller) { controller.Toggle(true); }
      let ps = tank.GetVehiclePS();
      if IsDefined(ps) { ps.SetDoorInteractionState(EVehicleDoor.seat_front_left,VehicleDoorInteractionState.Available,"HGBasilisk"); }
      tank.TurnVehicleOn(true);
      tank.TurnEngineOn(true);
      tank.PhysicsWakeUp();
      this.pending = false;
      this.message = "Basilisk ready. Enter normally or use Board Basilisk.";
      return;
    }
    this.pendingTime += delta;
    if this.pendingTime > 15.0 { this.Recall(); this.message = "Spawn timed out. Try another open area."; }
  }
}

@wrapMethod(QuickSlotsManager)
public final func SummonActiveVehicle(force: Bool) -> Void {
  let active = GameInstance.GetVehicleSystem(GetGameInstance()).GetActivePlayerVehicle(this.GetActiveVehicleType());
  if Equals(active.recordID,t"Vehicle.HG_Basilisk") { HGBasiliskSystem.Get().Deploy(); return; }
  wrappedMethod(force);
}

@wrapMethod(QuickSlotsManager)
public final func SummonVehicle(force: Bool,type: gamedataVehicleType,vehicle: TweakDBID,spawnOnlyOnValidRoad: Bool) -> Void {
  if Equals(vehicle,t"Vehicle.HG_Basilisk") { HGBasiliskSystem.Get().Deploy(); return; }
  wrappedMethod(force,type,vehicle,spawnOnlyOnValidRoad);
}
