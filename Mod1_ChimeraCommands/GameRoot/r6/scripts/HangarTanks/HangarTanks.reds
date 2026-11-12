// Chimera Commands: uses the real NPC, locomotion and boss AI.
public class HGTankSystem extends ScriptableSystem {
  private let chimeraID: EntityID;
  private let moveCommand: ref<AIMoveToCommand>;
  private let holdCommand: ref<AIHoldPositionCommand>;
  private let target: wref<GameObject>;
  private let previousTargetAttitude: EAIAttitude;
  private let previousOwnAttitude: EAIAttitude;
  private let mode: Int32;
  private let guardPosition: Vector4;
  private let moveDestination: Vector4;
  private let clock: Float;
  private let fireClock: Float;
  private let missileClock: Float;
  private let lastMessage: String;
  private let initialized: Bool;
  private let pending: Int32;
  private let pendingTime: Float;

  public static func Get() -> ref<HGTankSystem> {
    return GameInstance.GetScriptableSystemsContainer(GetGameInstance()).Get(n"HGTankSystem") as HGTankSystem;
  }
  public func OnAttach() -> Void {
    GameInstance.GetCallbackSystem().RegisterCallback(n"Session/BeforeEnd",this,n"BeforeEnd");
  }
  private cb func BeforeEnd(evt: ref<GameSessionEvent>) -> Void { this.ClearOrders(); }
  public func OnDetach() -> Void { this.target = null; this.moveCommand = null; this.holdCommand = null; }

  public func Gameplay() -> Bool {
    let p = GetPlayer(this.GetGameInstance());
    if !IsDefined(p) || p.IsDead() || GameInstance.GetSystemRequestsHandler().IsPreGame() { return false; }
    return !GameInstance.GetBlackboardSystem(p.GetGame()).Get(GetAllBlackboardDefs().UI_System).GetBool(GetAllBlackboardDefs().UI_System.IsInMenu)
      && !GameInstance.GetPhotoModeSystem(p.GetGame()).IsPhotoModeActive();
  }
  public func Message() -> String { return HGText.Text(this.lastMessage); }
  public func Mode() -> Int32 { return this.mode; }
  public func Chimera() -> ref<NPCPuppet> { return GameInstance.FindEntityByID(this.GetGameInstance(),this.chimeraID) as NPCPuppet; }
  public func Health(percent: Bool) -> Float {
    let npc = this.Chimera();
    if !IsDefined(npc) { return 0.0; }
    return GameInstance.GetStatPoolsSystem(npc.GetGame()).GetStatPoolValue(Cast<StatsObjectID>(npc.GetEntityID()),gamedataStatPoolType.Health,percent);
  }
  public func RegisterGarage() -> Void {
    let system = GameInstance.GetVehicleSystem(this.GetGameInstance());
    system.EnablePlayerVehicleID(t"Vehicle.HG_ChimeraDispatch",true);
  }
  public func RemoveGarage() -> Void {
    this.Recall(0);
    let system = GameInstance.GetVehicleSystem(this.GetGameInstance());
    system.EnablePlayerVehicleID(t"Vehicle.HG_ChimeraDispatch",false);
    this.initialized = true;
    this.lastMessage = "Garage entries removed. Disable automatic registration in the hangar settings to keep them removed.";
  }

  public func Deploy(kind: Int32) -> Bool {
    if kind != 2 { this.lastMessage = "Basilisk is provided separately by Flying Tank (Nexus 16138)."; return false; }
    let p = GetPlayer(this.GetGameInstance());
    if !this.Gameplay() || !IsDefined(p) { this.lastMessage = "Load a save and return to gameplay first."; return false; }
    if this.pending != 0 { this.lastMessage = "Wait for the current deployment to finish."; return false; }
    if VehicleComponent.IsMountedToVehicle(p.GetGame(),p.GetEntityID()) { this.lastMessage = "Exit the vehicle first."; return false; }
    if PlayerPuppet.GetSceneTier(p) > 2 { this.lastMessage = "Finish the current scene first."; return false; }
    if IsEntityInInteriorArea(p) { this.lastMessage = "Deploy outdoors in a large open area."; return false; }
    let position = p.GetWorldPosition() + p.GetWorldForward() * 22.0;
    let hit: TraceResult;
    if GameInstance.GetSpatialQueriesSystem(p.GetGame()).SyncRaycastByCollisionGroup(position + Vector4(0.0,0.0,8.0,0.0),position - Vector4(0.0,0.0,30.0,0.0),n"Static",hit,false,false) {
      position = Cast<Vector4>(hit.position);
      position.Z += 0.5;
    } else { this.lastMessage = "No ground found ahead. Face a clear level surface."; return false; }
    this.Recall(kind);
    let spec = new DynamicEntitySpec();
    spec.recordID = t"Character.HG_Chimera";
    spec.position = position;
    spec.orientation = p.GetWorldOrientation();
    spec.persistState = false;
    spec.persistSpawn = false;
    spec.alwaysSpawned = true;
    spec.tags = [n"HangarTanks"];
    let id = GameInstance.GetDynamicEntitySystem().CreateEntity(spec);
    this.chimeraID = id;
    this.pending = kind;
    this.pendingTime = 0.0;
    this.lastMessage = "Deployment requested...";
    return EntityID.IsDefined(id);
  }

  public func Recall(kind: Int32) -> Void {
    let system = GameInstance.GetDynamicEntitySystem();
    if kind == 0 || kind == 2 {
      this.ClearOrders();
      if EntityID.IsDefined(this.chimeraID) { system.DeleteEntity(this.chimeraID); }
      this.chimeraID = EntityID();
    }
    this.pending = 0;
    this.lastMessage = "Recalled.";
  }

  private func StopMove() -> Void {
    let npc = this.Chimera();
    if IsDefined(npc) {
      if IsDefined(this.moveCommand) { npc.GetAIControllerComponent().CancelCommand(this.moveCommand); }
      if IsDefined(this.holdCommand) { npc.GetAIControllerComponent().CancelCommand(this.holdCommand); }
    }
    this.moveCommand = null;
    this.holdCommand = null;
  }
  public func ClearOrders() -> Void {
    let npc = this.Chimera();
    this.StopMove();
    if IsDefined(npc) {
      if IsDefined(this.target) && IsDefined(this.target.GetAttitudeAgent()) {
        this.target.GetAttitudeAgent().SetAttitudeTowards(npc.GetAttitudeAgent(),this.previousTargetAttitude);
        npc.GetAttitudeAgent().SetAttitudeTowards(this.target.GetAttitudeAgent(),this.previousOwnAttitude);
      }
      npc.GetTargetTrackerComponent().ClearThreats();
      npc.GetAIControllerComponent().SetBehaviorArgument(n"CombatTarget",ToVariant(null));
      if !npc.IsDead() { NPCPuppet.ChangeHighLevelState(npc,gamedataNPCHighLevelState.Relaxed); }
    }
    this.target = null;
    this.mode = 0;
  }
  private func Hold() -> Void {
    let npc = this.Chimera();
    if !IsDefined(npc) { return; }
    this.StopMove();
    this.holdCommand = new AIHoldPositionCommand();
    this.holdCommand.duration = -1.0;
    npc.GetAIControllerComponent().SendCommand(this.holdCommand);
  }

  // Public command API is used by both CET hotkeys and the Capricorn bridge.
  // 0 stop; 1 follow; 2 guard; 3 attack crosshair target; 4 recall.
  public func Command(order: Int32) -> Bool {
    if order == 4 { this.Recall(2); return true; }
    let npc = this.Chimera();
    let p = GetPlayer(this.GetGameInstance());
    if !this.Gameplay() || !IsDefined(npc) || npc.IsDead() || this.Health(true) <= 0.0 { this.lastMessage = "Deploy a live Chimera first."; return false; }
    if order == 3 {
      let selected = GameInstance.GetTargetingSystem(p.GetGame()).GetLookAtObject(p,true,true);
      return this.Attack(selected);
    }
    this.ClearOrders();
    this.mode = order;
    if order == 0 { this.Hold(); this.lastMessage = "CHIMERA: cease fire / hold position."; }
    if order == 1 { this.lastMessage = "CHIMERA: follow V, defend against nearby hostiles."; }
    if order == 2 { this.guardPosition = npc.GetWorldPosition(); this.Hold(); this.lastMessage = "CHIMERA: guard this position (60 m)."; }
    return true;
  }
  public func Attack(selected: ref<GameObject>) -> Bool {
    let npc = this.Chimera();
    if !this.Gameplay() || !IsDefined(npc) || npc.IsDead() || this.Health(true) <= 0.0 || !IsDefined(selected) || !selected.IsAttached() || selected == npc || selected.IsPlayer() || (!selected.IsNPC() && !selected.IsVehicle()) {
      this.lastMessage = "Aim at a living NPC or vehicle, then issue Attack.";
      return false;
    }
    if Vector4.Distance(npc.GetWorldPosition(),selected.GetWorldPosition()) > 180.0 { this.lastMessage = "Target beyond 180 m command range."; return false; }
    this.ClearOrders();
    this.mode = 3;
    this.AssignTarget(selected);
    this.lastMessage = "CHIMERA: destroy designated target.";
    return true;
  }
  private func AssignTarget(selected: ref<GameObject>) -> Void {
    let npc = this.Chimera();
    if !IsDefined(npc) || !IsDefined(selected) { return; }
    this.StopMove();
    this.target = selected;
    if IsDefined(selected.GetAttitudeAgent()) {
      this.previousTargetAttitude = selected.GetAttitudeAgent().GetAttitudeTowards(npc.GetAttitudeAgent());
      this.previousOwnAttitude = npc.GetAttitudeAgent().GetAttitudeTowards(selected.GetAttitudeAgent());
      selected.GetAttitudeAgent().SetAttitudeTowards(npc.GetAttitudeAgent(),EAIAttitude.AIA_Hostile);
      npc.GetAttitudeAgent().SetAttitudeTowards(selected.GetAttitudeAgent(),EAIAttitude.AIA_Hostile);
    }
    npc.GetTargetTrackerComponent().AddThreat(selected,true,selected.GetWorldPosition(),1.0,-1.0,true);
    npc.GetAIControllerComponent().SetBehaviorArgument(n"CombatTarget",ToVariant(selected));
    NPCPuppet.ChangeHighLevelState(npc,gamedataNPCHighLevelState.Combat);
    AIActionHelper.TryStartCombatWithTarget(npc,selected);
  }

  public func MoveTo(position: Vector4) -> Bool {
    let npc = this.Chimera();
    if !IsDefined(npc) { return false; }
    this.StopMove();
    let command = new AIMoveToCommand();
    let world: WorldPosition;
    WorldPosition.SetVector4(world,position);
    AIPositionSpec.SetWorldPosition(command.movementTarget,world);
    command.movementType = moveMovementType.Walk;
    command.ignoreNavigation = false;
    command.useStart = true;
    command.useStop = true;
    command.desiredDistanceFromTarget = 1.0;
    command.finishWhenDestinationReached = true;
    this.moveCommand = command;
    this.moveDestination = position;
    return npc.GetAIControllerComponent().SendCommand(command);
  }
  // Vehicles are not valid native puppet combat targets. Fire the Chimera's
  // actual equipped cannon/missile weapons at them, with their native damage.
  private func FireOnVehicle(vehicle: ref<VehicleObject>, missiles: Bool) -> Void {
    let npc = this.Chimera();
    let slots: array<TweakDBID>;
    if missiles { slots = [t"AttachmentSlots.LeftShoulderTrack",t"AttachmentSlots.RightShoulderTrack"]; }
    else { slots = [t"AttachmentSlots.MetalstormWeapon"]; }
    let position = vehicle.GetWorldPosition() + Vector4(0.0,0.0,1.0,0.0);
    for slot in slots {
      let weapon = GameInstance.GetTransactionSystem(npc.GetGame()).GetItemInSlot(npc,slot) as WeaponObject;
      if IsDefined(weapon) { AIWeapon.Fire(npc,weapon,EngineTime.ToFloat(GameInstance.GetSimTime(npc.GetGame())),1.0,gamedataTriggerMode.SemiAuto,position,vehicle); }
    }
  }
  public func Tick(delta: Float, autoRegister: Bool) -> Void {
    let p = GetPlayer(this.GetGameInstance());
    if !IsDefined(p) || GameInstance.GetSystemRequestsHandler().IsPreGame() { return; }
    if !this.initialized { if autoRegister { this.RegisterGarage(); } this.initialized = true; }
    if this.pending > 0 {
      this.pendingTime += delta;
      let entity: ref<GameObject> = this.Chimera();
      if IsDefined(entity) && entity.IsAttached() {
        let npc = this.Chimera();
        npc.GetAttitudeAgent().SetAttitudeGroupUnsavable(n"player");
        npc.GetAttitudeAgent().SetAttitudeTowards(p.GetAttitudeAgent(),EAIAttitude.AIA_Friendly);
        p.GetAttitudeAgent().SetAttitudeTowards(npc.GetAttitudeAgent(),EAIAttitude.AIA_Friendly);
        this.Command(0);
        this.pending = 0;
        this.lastMessage = "Chimera deployed. Awaiting orders.";
      } else if this.pendingTime > 15.0 {
        let failedKind = this.pending;
        this.Recall(failedKind);
        this.lastMessage = "Spawn timed out. Move to open ground, retry.";
      }
    }
    if !this.Gameplay() { return; }
    let npc = this.Chimera();
    if !IsDefined(npc) || npc.IsDead() || this.Health(true) <= 0.0 {
      if this.mode != 0 { this.ClearOrders(); this.lastMessage = "CHIMERA: disabled."; }
      return;
    }
    this.fireClock += delta;
    this.missileClock += delta;
    let vehicleTarget = this.target as VehicleObject;
    if this.mode == 3 && IsDefined(vehicleTarget) && vehicleTarget.IsAttached() && !vehicleTarget.IsDestroyed() {
      if this.fireClock >= 0.3 { this.FireOnVehicle(vehicleTarget,false); this.fireClock = 0.0; }
      if this.missileClock >= 1.5 { this.FireOnVehicle(vehicleTarget,true); this.missileClock = 0.0; }
    }
    this.clock += delta;
    if this.clock < 0.75 { return; }
    this.clock = 0.0;
    if this.mode == 0 {
      npc.GetTargetTrackerComponent().ClearThreats();
      npc.GetAIControllerComponent().SetBehaviorArgument(n"CombatTarget",ToVariant(null));
      NPCPuppet.ChangeHighLevelState(npc,gamedataNPCHighLevelState.Relaxed);
      return;
    }
    if this.mode == 3 && !IsDefined(this.target) {
      this.ClearOrders(); this.Hold(); this.lastMessage = "CHIMERA: target unloaded; holding position."; return;
    }
    if IsDefined(this.target) {
      let targetNPC = this.target as NPCPuppet;
      let targetVehicle = this.target as VehicleObject;
      let finished = !this.target.IsAttached() || (IsDefined(targetNPC) && (targetNPC.IsDead() || ScriptedPuppet.IsDefeated(targetNPC))) || (IsDefined(targetVehicle) && targetVehicle.IsDestroyed());
      if this.mode == 2 && Vector4.Distance(this.target.GetWorldPosition(),this.guardPosition) > 65.0 { finished = true; }
      if finished {
        let prior = this.mode;
        this.ClearOrders();
        this.mode = prior == 3 ? 0 : prior;
        this.lastMessage = "CHIMERA: target neutralized or disengaged.";
        if this.mode == 0 { this.Hold(); }
      } else { return; }
    }
    if this.mode == 1 || this.mode == 2 {
      let center = this.mode == 1 ? p.GetWorldPosition() : this.guardPosition;
      for enemy in npc.GetNPCsAroundObject(100.0) {
        if enemy != npc && !enemy.IsDead() && !ScriptedPuppet.IsDefeated(enemy) && Vector4.Distance(enemy.GetWorldPosition(),center) <= 60.0 && Equals(GameObject.GetAttitudeTowards(enemy,p),EAIAttitude.AIA_Hostile) {
          this.AssignTarget(enemy);
          return;
        }
      }
      let destination = this.mode == 1 ? p.GetWorldPosition() - p.GetWorldForward() * 12.0 : this.guardPosition;
      let distance = Vector4.Distance(npc.GetWorldPosition(),destination);
      if distance > 10.0 && distance < 220.0 {
        if !IsDefined(this.moveCommand) || Vector4.Distance(destination,this.moveDestination) > 6.0 || (!npc.GetAIControllerComponent().IsCommandExecuting(n"AIMoveToCommand",true) && !npc.GetAIControllerComponent().IsCommandWaiting(n"AIMoveToCommand",true)) { this.MoveTo(destination); }
      } else if distance <= 5.0 && IsDefined(this.moveCommand) { this.StopMove(); }
    }
  }
}

// Initialize only our clone, bypassing the global quest's 'chimera_defeated'
// branch. Keep the native stat groups, weapons, hit shapes and phase listener.
@wrapMethod(ChimeraComponent)
public func OnGameAttach() -> Void {
  let npc = this.GetOwner() as NPCPuppet;
  if !IsDefined(npc) || NotEquals(npc.GetRecordID(),t"Character.HG_Chimera") { wrappedMethod(); return; }
  this.m_owner = npc;
  this.m_ownerId = npc.GetEntityID();
  this.m_player = GetPlayer(npc.GetGame());
  this.m_statPoolSystem = GameInstance.GetStatPoolsSystem(npc.GetGame());
  this.m_targetTrackerComponent = npc.GetTargetTrackerComponent();
  this.m_weakspotComponent = npc.GetWeakspotComponent();
  this.m_defeatedOnAttach = false;
  this.m_healthListener = new ChimeraHealthChangeListener();
  this.m_healthListener.SetValue(80.0);
  this.m_healthListener.SetOwner(npc);
  this.m_statPoolSystem.RequestRegisteringListener(Cast<StatsObjectID>(this.m_ownerId),gamedataStatPoolType.Health,this.m_healthListener);
  this.DisableAllHitShapes();
  this.EnablePhase1HitShapes();
  StatusEffectHelper.ApplyStatusEffect(npc,t"Chimera.Phase1",this.m_ownerId);
  StatusEffectHelper.ApplyStatusEffect(npc,t"Chimera.HideBossHealthBar",this.m_ownerId);
  AnimationControllerComponent.SetAnimWrapperWeight(npc,n"section1Locomotion",1.0);
}

// The quest's last 1% requires a scripted finisher. Our owned clone instead
// becomes a destroyed wreck at that threshold; the quest boss is unaffected.
@wrapMethod(ChimeraComponent)
public final func ApplyPhase3() -> Void {
  if NotEquals(this.m_owner.GetRecordID(),t"Character.HG_Chimera") { wrappedMethod(); return; }
  StatusEffectHelper.RemoveStatusEffect(this.m_owner,t"Chimera.Phase2");
  this.m_owner.ScheduleAppearanceChange(n"mch_004__militech_chimera__basic_01_burnt");
  GameObject.StartReplicatedEffectEvent(this.m_owner,n"explode_Death");
  this.m_statPoolSystem.RequestSettingStatPoolValue(Cast<StatsObjectID>(this.m_ownerId),gamedataStatPoolType.Health,0.0,this.m_owner,true);
}

@wrapMethod(QuickSlotsManager)
public final func SummonActiveVehicle(force: Bool) -> Void {
  let active = GameInstance.GetVehicleSystem(GetGameInstance()).GetActivePlayerVehicle(this.GetActiveVehicleType());
  if Equals(active.recordID,t"Vehicle.HG_ChimeraDispatch") { HGTankSystem.Get().Deploy(2); return; }
  wrappedMethod(force);
}
@wrapMethod(QuickSlotsManager)
public final func SummonVehicle(force: Bool,type: gamedataVehicleType,vehicle: TweakDBID,spawnOnlyOnValidRoad: Bool) -> Void {
  if Equals(vehicle,t"Vehicle.HG_ChimeraDispatch") { HGTankSystem.Get().Deploy(2); return; }
  wrappedMethod(force,type,vehicle,spawnOnlyOnValidRoad);
}
