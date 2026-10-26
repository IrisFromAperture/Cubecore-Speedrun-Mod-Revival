//*****************************************************
//====Save The Cube====
//bring the cube to the moon
//*****************************************************


//TODO
//1. fix filter list
//2. make system to respawn cube from dropper if it dies
//3. make system to automatically assign every elevator the cube trigger
//4. fix any map-specific errors along the way
//5. make ending dropper for during finale 4
//6. add specific triggers to all fizzlers to make them disable for the cube

CUBE_SPAWNS <- {} //??

function CubeCorePrecache(){
    smsm.PrecacheModel("models/srmod/cubecore.mdl", true);
    smsm.PrecacheModel("models/props/metal_box.mdl", true); // just in case
    smsm.PrecacheModel("models/props_underground/underground_boxdropper_cage.mdl", true);
    smsm.PrecacheModel("models/props_underground/underground_boxdropper.mdl", true);

    self.PrecacheSoundScript("cubecore.fuckthisgame");
}

function CubeCorePostSpawn(){ //?? isnt there already a function for this? or is this like post-post spawn

}

function CubeCoreLoad(){
    //create playerproxy for later
    local playerproxy = Entities.CreateByClassname("logic_playerproxy");
    EntFireByHandle(playerproxy, "AddOutput", "targetname cubecore_playerproxy",0,null,null);

    FixAllFilters();
    //EntFire("@exit_elevator_cleanser", "disable", "", 0.0);

    switch(GetMapName()){
    case "sp_a1_intro1":
        SendToConsole("contimes_toggle");
        SendToConsole("sv_cheats 1");
        CreateCubeDropper(-1312,4448,3696, 0);
        CreateTriggerCubeHoldLockOrSomething(-688,3110,2550,true);
        local cubeSpawnDelay = 11;
        CreateCubeCore(-1300,4440,3660,cubeSpawnDelay+0.5);
        EntFire("cubecore_cube", "EnableMotion", "", cubeSpawnDelay+0.75);
        EntFire("cubecore_dropper", "SetAnimation", "open", cubeSpawnDelay+0.5);
        EntFire("cubecore_dropper", "SetAnimation", "close", cubeSpawnDelay+2);

        EntFire("glass_break_193x193_d1", "SetAnimation", "collapse1", cubeSpawnDelay+2.25);
        EntFire("glass_break_193x193_d2", "SetAnimation", "collapse1", cubeSpawnDelay+2.25);
        EntFire("glass_break_193x193_d1", "EnableDraw", "", cubeSpawnDelay+2.25);
        EntFire("glass_break_193x193_d2", "EnableDraw", "", cubeSpawnDelay+2.25);
        EntFire("whole_glass_piece", "DisableDraw", "", cubeSpawnDelay+2.25);
        EntFire("glass_break", "Kill", "", 0);
        EntFire("aud_opening_glass_break", "PlaySound", "", cubeSpawnDelay+2.25);

        FixAllFilters(cubeSpawnDelay+0.5);

        break
    default:
        CreateCubeCore(null,null,null); //setting x,y,z all to null makes cubecore spawn on player
        GrabAndLockCubeFor(2);
        //FixAllFilters();
        OriginToName();
        break;
    }
    
}

CUBECORE_CORE <- null;

cubeTimer <- 0;

function CubeCoreUpdate(){ //use this func to detect if the cube is dead, since it updates constantly? but how to detect where cube died? maybe keep track of position? thatll be a VERY long function though
    cubeTimer++;
    if(cubeTimer==220){
        CUBECORE_CORE.EmitSound("cubecore.fuckthisgame");

        EntFireByHandle(CUBECORE_CORE, "SetIdleSequence", "sphere_plug_shifty_swagger", 0.05, null,null);
        EntFireByHandle(CUBECORE_CORE, "SetIdleSequence", "sphere_plug_shake_CW_scared", 0.45, null,null);
        EntFireByHandle(CUBECORE_CORE, "SetIdleSequence", "sphere_plug_spin_cycle_B", 0.75, null,null);
        EntFireByHandle(CUBECORE_CORE, "SetIdleSequence", "sphere_plug_awkward_blink", 1.35, null,null);
        EntFireByHandle(CUBECORE_CORE, "SetIdleSequence", "sphere_plug_idle_sceptical", 2, null,null);
    }
}

function FixAllFilters(){ //works
    if(GetMapName() in FILTER_FIX_LIST){
        foreach(i, filter in FILTER_FIX_LIST[GetMapName()]){
            local name = null;
            if ("name" in filter) {
                name = filter.name;
                EntFire(name, "kill", "", 0.0);
                //SendToConsole("say fucked up vphys clip '"+name+"'");
            } else {
                SendToConsole("say you fucked up on the filter");
            }
        }
        
    }
}

function OriginToName(){ //cant get the name for some reason? only the number and type? i dont even know what the number means
    if(GetMapName() in FILTER_FIX_LIST){
        local ent = null;
        foreach(i, filter in FILTER_FIX_LIST[GetMapName()]){
            local name = null;
            if(!("name" in filter)){
                local type = null;
                ent = Entities.FindByClassnameNearest("trigger_portal_cleanser", filter.origin, 8);
                if(!ent) {
                    ent = Entities.FindByClassnameNearest("func_clip_vphysics", filter.origin, 8);
                    type = "physics clip";
                } else {
                    type = "fizzler";
                }
                if (ent != null) {
                    local namei = ent.GetName();
                    SendToConsole("say entity:");
                    SendToConsole("say "+ent);
                } else {
                    SendToConsole("say no entity found");
                }
            }
        }
    }
}

function FixAlldaFilters(){ //doesnt work, i think something with how the filter is applied/triggered, wasier to just kill the clips and disable fizzlers imo
    if(GetMapName() in FILTER_FIX_LIST){
        //SendToConsole("say found map");
        foreach(i, filter in FILTER_FIX_LIST[GetMapName()]){
            local name = null;
            if(!("name" in filter)){
                local ent = Entities.FindByClassnameNearest("trigger_portal_cleanser", filter.origin, 8);
                if(!ent) {ent = Entities.FindByClassnameNearest("func_clip_vphysics", filter.origin, 8);}
                name = GetMapName()+"_fixedfilter_"+i;
                //SendToConsole("say using GetMapName, name is now "+name);
                //if(ent){EntFireByHandle(ent, "AddOutput", "targetname "+name, 0, null, null);}
                EntFire(ent, "Kill", "", 0.0);
            }else{
                name = filter.name;
                //SendToConsole("say using filter.name, name is now "+name);
                //if(!("cleanser" in name)){EntFire(name, "kill", "", 0.0);}
                EntFire(name, "Kill", "", 0.0);
            }
            //local filterName = null;
            //if("filter" in filter){filterName = filter.filter;}
            //FixFilter(name, filterName);
        }
    }
}

//creates filter entity (or entities) and hook it into the fizzler/vclip
//so that cube core can freely pass through it
//entity - fizzler/vclip that has to be fixed
//existingFilter - name of a filter that is originally assigned to the entity.

function FixFilter(entity, existingFilter=null){ //doesnt work, see func above
    local filter = Entities.CreateByClassname("filter_activator_name");
    local filtername = entity+"_hackyfilter";
    EntFireByHandle(filter,"AddOutput","targetname "+filtername,0,null,null);
    EntFireByHandle(filter,"AddOutput","filtername cubecore_cube",0,null,null);
    EntFireByHandle(filter,"AddOutput","negated 1",0,null,null);
    if(existingFilter!=null){
        //entity does have a filter, use filter_multi to connect old and new one
        local filtermulti = Entities.CreateByClassname("filter_multi");
        local filtermultiname = entity+"_hackymulti";
        EntFireByHandle(filtermulti,"AddOutput","targetname "+filtermultiname,0,null,null);
        EntFireByHandle(filtermulti,"AddOutput","filter01 "+existingFilter,0,null,null);
        EntFireByHandle(filtermulti,"AddOutput","filter02 "+filtername,0,null,null);
        EntFireByHandle(filtermulti,"RunScriptCode","smsm.RefreshEntity(self)",0.05,null,null);
        EntFire(entity,"AddOutput","filtername "+filtermultiname)
    }else{ 
        //entity doesnt have any filters, just add it
        EntFire(entity,"AddOutput","filtername "+filtername)
    }
    //janky hack mate >:]
    EntFire(entity,"RunScriptCode","smsm.RefreshEntity(self)",0.1);
    //TODO: add spawn in plugin (24)
}

//function naming is my pashion
function CreateTriggerCubeHoldLockOrSomething(x,y,z,startLocked){ //w function name, whoever wrote it
    local endTrigger = Entities.FindByClassnameNearest("trigger_once", Vector(x,y,z), 20);
    //just to be sure lmao, probably useless
    //if(!endTrigger) {}
    //endTrigger = Entities.FindByClassnameNearest("trigger_multiple", Vector(x,y,z), 20);
    //SendToConsole("say found entity: "+endTrigger);
    //SendToConsole("say running end trigger script");
    EntFireByHandle(endTrigger, "AddOutput", "targetname cubecore_fixed_end_trigger",0,null,null);

    //disable and enable trigger whether player is holding a cube
    if(startLocked){EntFire("cubecore_fixed_end_trigger", "Disable");}
    //SendToConsole("say if loop triggered");
    //EntFire("cubecore_cube", "AddOutput", "OnPhysGunDrop cubecore_fixed_end_trigger:Disable::0:-1",0.5); //both of these moved to PostCreateCubeCore()
    //EntFire("cubecore_cube", "AddOutput", "OnPlayerPickup cubecore_fixed_end_trigger:Enable::0:-1",0.5);

    //make sure the player cannot drop the cube when transitioning
    EntFireByHandle(endTrigger, "AddOutput", "OnStartTouch cubecore_playerproxy:ForceVMGrabController::0:-1",0,null,null);
    EntFireByHandle(endTrigger, "AddOutput", "OnStartTouch cubecore_playerproxy:SetDropEnabled:0:0:-1",0,null,null);
}

function GrabAndLockCubeFor(waitTime){ //also good function, only had to tweak timing to get it to work
    //SendToConsole("say tryig grab in " seconds");
    EntFire("cubecore_playerproxy", "ForceVMGrabController", "", 0);
    EntFire("cubecore_playerproxy", "SetDropEnabled", "0", 0);

    EntFire("cubecore_cube", "Use", "", 0.25, GetPlayer()); //0.25s delay works best from testing

    EntFire("cubecore_playerproxy", "ResetGrabControllerBehavior", "", waitTime);
    EntFire("cubecore_playerproxy", "SetDropEnabled", "1", waitTime);
}



function CreateCubeDropper(x,y,z,rot){
    local dropper = Entities.CreateByClassname("prop_dynamic");
    EntFireByHandle(dropper, "AddOutput", "targetname cubecore_dropper", 0, null, null);
    dropper.SetOrigin(Vector(x,y,z-96));
    dropper.SetAngles(0,0,0);
    dropper.SetModel("models/props_underground/underground_boxdropper.mdl");

    local dropperCage = Entities.CreateByClassname("prop_dynamic");
    EntFireByHandle(dropperCage, "AddOutput", "solid 6", 0, null, null);
    EntFireByHandle(dropperCage, "AddOutput", "targetname cubecore_dropper_cage", 0, null, null);
    dropperCage.SetOrigin(Vector(x,y,z-96));
    dropper.SetAngles(0,0,0);
    dropperCage.SetModel("models/props_underground/underground_boxdropper_cage.mdl");

    local dropperBlack = Entities.CreateByClassname("prop_dynamic");
    EntFireByHandle(dropperBlack, "Color", "0 0 0", 0, null, null);
    dropperBlack.SetOrigin(Vector(x,y,z+8));
    dropper.SetAngles(0,0,0);
    dropperBlack.SetModel("models/props_underground/underground_boxdropper.mdl");
}

function CreateCubeCore(x,y,z, delay=0){ //yippee! spawning the cube in is so easy!
    //For some reason making functional cubes or cores with script functions is nearly impossible.
    //spawning the cube using commands. it always has targetname "cube".
    //needs to wait 1 tick before trying to modify it.
    SendToConsole("ent_create_portal_reflector_cube")
    SendToConsole("ent_create npc_personality_core")
    //SendToConsole("say xyz is x= "+x+", y= "+y+", z= "+z);
    //SendToConsole("say player angles are: "+player.GetAngles());
    //SendToConsole("say maybe player x is: "+player.GetOrigin().x);
    //SendToConsole("say "+sin(player.GetAngles().y*(pi/180)));
    if (x==null || y==null || z==null) {
        local pi = 3.14159265358; //mm, pie
        local rad = pi/180;
        local offsetx = 15*cos(rad*player.GetAngles().y); //offset the cube 10 units in the direction the player is looking
        local offsety = 15*sin(rad*player.GetAngles().y); //offset the cube 10 units in the direction the player is looking
        x = player.GetOrigin().x+offsetx;
        y = player.GetOrigin().y+offsety;
        z = player.GetOrigin().z+30;
    }
    EntFire(self.GetName(), "RunScriptCode", "PostCreateCubeCore("+x+","+y+","+z+")", 0.2+delay);
}

function PostCreateCubeCore(x,y,z){ //oh, all the important stuff happens here
    local cubeEnt = Entities.FindByName(null,"cube");
    EntFireByHandle(cubeEnt, "AddOutput", "targetname cubecore_cube", 0, null, null);
    //cubeEnt.SetModel("models/srmod/cubecore.mdl");
    //SendToConsole("say xyz is x= "+x+", y= "+y+", z= "+z);
    cubeEnt.SetOrigin(Vector(x,y,z));
    //if(x != null && y != null && z != null) {
    //    SendToConsole("say none of xyz is null, setting to coords");
    //    cubeEnt.SetOrigin(Vector(x,y,z));
    //} else {
    //    SendToConsole("say one of xyz is null, setting to player spawn");
    //    cubeEnt.SetOrigin(player.GetOrigin());
    //}
    cubeEnt.SetAngles(0,0,0);
    EntFireByHandle(cubeEnt, "DisableDraw", "", 0, null, null); //setting cube to have the cubecore model and to be visible works to make it interactable, but orientation is wrong and doesnt animate
    //EntFireByHandle(cubeEnt, "AddOutput", "solid 0", 0, null, null);
    EntFireByHandle(cubeEnt, "AddOutput", "solid 6", 0, null, null);
    //EntFireByHandle(cubeEnt, "DisableMotion", "", 0, null, null);
    
    local coreHandler = Entities.CreateByClassname("info_target");
    //coreHandler.SetOrigin(player.GetOrigin());
    coreHandler.SetOrigin(Vector(x,y,z));
    coreHandler.SetAngles(0,90,0);
    EntFireByHandle(coreHandler, "AddOutput", "targetname cubecore_core_handler", 0, null, null);
    EntFireByHandle(coreHandler, "SetParent", "cubecore_cube", 0, null, null);
    //coreHandler.setParent(cubecore_cube);


    local coreEnt = null;
    local newCoreEnt = null;
    while(newCoreEnt = Entities.FindByClassname(coreEnt,"npc_personality_core")){coreEnt = newCoreEnt;}
    //local coreEnt = Entities.FindByName(null, "npc_personality_core");
    coreEnt.SetModel("models/srmod/cubecore.mdl");
    //coreEnt.SetOrigin(player.GetOrigin());
    coreEnt.SetOrigin(Vector(x,y,z));
    coreEnt.SetAngles(0,90,0);
    //coreEnt.SetParent("cubeEnt"); //setting the core parent to cubecore_cube or coreHandler makes the core move, be grabbable, and pass through cube blocks, but does not depress buttons like cube and can roll. 
    //EntFireByHandle(coreEnt, "DisableDraw", "", 0, null, null);
    EntFireByHandle(coreEnt, "DisableMotion", "", 0, null, null);
    EntFireByHandle(coreEnt, "AddOutput", "targetname cubecore_core", 0, null, null);
    EntFireByHandle(coreEnt, "SetParent", "cubecore_cube", 0, null, null); //originally "cubecore_core_parent"
    EntFireByHandle(coreEnt, "AddOutput", "solid 0", 0, null, null);
    EntFireByHandle(coreEnt, "SetIdleSequence", "sphere_plug_idle_happy", 0.5, null, null);
    EntFireByHandle(coreEnt, "DisablePickup", "", 0, null, null);
    EntFireByHandle(coreEnt, "RunScriptCode","smsm.RefreshEntity(self)",0.1, null, null);
    CUBECORE_CORE = coreEnt;

    local measureMovement = Entities.CreateByClassname("logic_measure_movement");
    EntFireByHandle(measureMovement, "AddOutput", "targetname cubecore_move", 0, null, null);
    EntFireByHandle(measureMovement, "AddOutput", "targetreference cubecore_move", 0, null, null);
    EntFireByHandle(measureMovement, "AddOutput", "measurereference cubecore_move", 0, null, null);
    EntFireByHandle(measureMovement, "AddOutput", "measuretarget cubecore_core_handler", 0, null, null);
    EntFireByHandle(measureMovement, "AddOutput", "target cubecore_core", 0, null, null);
    EntFireByHandle(measureMovement, "RunScriptCode", "smsm.RefreshEntity(self)", 0.1, null, null);

    EntFire("cubecore_cube", "AddOutput", "OnPhysGunDrop cubecore_fixed_end_trigger:Disable::0:-1",0.5);
    EntFire("cubecore_cube", "AddOutput", "OnPlayerPickup cubecore_fixed_end_trigger:Enable::0:-1",0.5);

    FizzlerTrigger();
}

//maybe repurpose this as a cube-respawning dropper? or plop a bunch of droppers in convenient spots, rememer where the cube last was, then if it dies choose the closest dropper and respawn?
//but also how to make sure the cube doesnt spawn too far back, to where it cant be obtained? how to make player not see the cube when they spawn in and are just sitting there for .2 seconds?
function CreateStartDropper(x,y,z, pitch, yaw, roll, delay){ //didnt that already happen? 

}

//should totally make it the incinerator so you just took the cube there for nothing
function CreateEndDropper(pos, angles){

}




// list of all fucking vphys clips and fizzlers in the game so I can patch them for the cube omg kill me
//yeah fuck this list, also why are all the levels out of order :sob:

FILTER_FIX_LIST <- {
    sp_a4_tb_polarity=[
        {name="box_vclip"},
        {name="@exit_door-door_physics_clip",filter="@exit_door-weighted_cube_filter"},
        {origin=Vector(444,672,320)},
        {name="door_0-door_physics_clip",filter="door_0-weighted_cube_filter"},
        {name="@exit_elevator_cleanser"},
    ],
    sp_a2_bridge_intro=[
        {name="@exit_door-door_physics_clip",filter="@exit_door-weighted_cube_filter"},
        {name="door_52-door_physics_clip",filter="door_52-weighted_cube_filter"},
        {name="box_dropper_01-cube_dropper_box_reenter_clip"}
    ],
    sp_a1_intro2=[
        {name="@exit_door-door_physics_clip",filter="@exit_door-weighted_cube_filter"},
        {name="@entry_door-door_physics_clip",filter="@entry_door-weighted_cube_filter"}
    ],
    sp_a1_intro3=[
        {name="door_0-door_physics_clip",filter="door_0-weighted_cube_filter"},
        {name="door_3-door_physics_clip",filter="door_3-weighted_cube_filter"}
    ],
    sp_a4_jump_polarity=[
        {name="fizzler1"},
        {name="fling_cleanser"},
        {name="InstanceAuto5-$cleanser_name"},
        {name="InstanceAuto70-$cleanser_name"},
        {name="@entry_door-door_physics_clip",filter="@entry_door-weighted_cube_filter"},
        {name="@exit_elevator_cleanser"},
    ],
    sp_a1_intro6=[
        {name="room_1_exit_door-door_physics_clip",filter="room_1_exit_door-weighted_cube_filter"},
        {name="room_2_entry_door-door_physics_clip",filter="room_2_entry_door-weighted_cube_filter"},
        {name="cube_dropper-cube_dropper_box_reenter_clip"},
        {name="room_2_exit_door-door_physics_clip",filter="room_2_exit_door-weighted_cube_filter"},
        {name="room_1_entry_door-door_physics_clip",filter="room_1_entry_door-weighted_cube_filter"}
    ],
    sp_a4_finale2=[
        {origin=Vector(-3151.99,-1640,-256)},
        {origin=Vector(800.42,704,-127.75)},
        {origin=Vector(704,-160,64)},
        {origin=Vector(-758,-1216,-448)},
        {origin=Vector(801,704,-135.99)},
        {origin=Vector(704,-160,-64)},
    ],
    sp_a2_laser_vs_turret=[
        {name="ratman_entry_clip"},
        {name="door_0-door_physics_clip",filter="door_0-weighted_cube_filter"},
        {name="@exit_door-door_physics_clip",filter="@exit_door-weighted_cube_filter"}
    ],
    sp_a2_bts4=[
        {origin=Vector(2958,-4928,6716.02)},
        {origin=Vector(928,-6912,6336)},
        {origin=Vector(928,-6912,6336)},
        {origin=Vector(928,-6912,6336)},
        {origin=Vector(928,-6912,6336)},
        {name="InstanceAuto31-$cleanser_name"},
    ],
    sp_a2_dual_lasers=[
        {name="door_0-door_physics_clip",filter="door_0-weighted_cube_filter"},
        {name="door_1-door_physics_clip",filter="door_1-weighted_cube_filter"}
    ],
    sp_a4_tb_trust_drop=[
        {name="door_0-door_physics_clip",filter="door_0-weighted_cube_filter"},
        {name="@exit_door-door_physics_clip",filter="@exit_door-weighted_cube_filter"},
        {name="@exit_elevator_cleanser"},
    ],
    sp_a4_tb_intro=[
        {name="door_0-door_physics_clip",filter="door_0-weighted_cube_filter"},
        {name="@exit_door-door_physics_clip",filter="@exit_door-weighted_cube_filter"},
        {origin=Vector(1664,512,-508)},
        {name="@exit_elevator_cleanser"},
    ],
    sp_a2_catapult_intro=[
        {name="door_1-door_physics_clip",filter="door_1-weighted_cube_filter"},
        {name="simple_physics_prop_clip",filter="simple_physics_prop_filter"},
        {name="@exit_door-door_physics_clip",filter="@exit_door-weighted_cube_filter"},
        {name="cube_dropper-cube_dropper_box_reenter_clip"}
    ],
    sp_a2_core=[
        {name="pit_clip",filter="filter_name"},
        {name="rv_trap_portal_surf_cleanser"},
        {origin=Vector(-1840,0,-64)},
    ],
    sp_a2_column_blocker=[
        {name="@exit_door-door_physics_clip",filter="@exit_door-weighted_cube_filter"},
        {name="door_0-door_physics_clip",filter="door_0-weighted_cube_filter"},
        {name="cube_dropper_1-cube_dropper_box_reenter_clip"},
        {name="cube_dropper_2-cube_dropper_box_reenter_clip"}
    ],
    sp_a4_tb_catch=[
        {name="@destruction_relay"},
        {name="@destruction_relay"},
        {name="@exit_door-door_physics_clip",filter="@exit_door-weighted_cube_filter"},
        {name="door_0-door_physics_clip",filter="door_0-weighted_cube_filter"},
        {origin=Vector(508,-480,608)},
        {name="@exit_elevator_cleanser"},
    ],
    sp_a1_intro5=[
        {name="door_0-door_physics_clip",filter="door_0-weighted_cube_filter"},
        {name="door_1-door_physics_clip",filter="door_1-weighted_cube_filter"},
        {name="cube_dropper_2-cube_dropper_box_reenter_clip"},
        {name="cube_dropper_1-cube_dropper_box_reenter_clip"},
    ],
    sp_a2_laser_stairs=[
        {name="door_1-door_physics_clip",filter="door_1-weighted_cube_filter"},
        {name="door_0-door_physics_clip",filter="door_0-weighted_cube_filter"},
        {name="cube_dropper_01-cube_dropper_box_reenter_clip"}
    ],
    sp_a1_intro7=[
        {name="sphere_clip"},
        {name="sphere_clip"},
        {name="portal_blocker"},
        {name="sphere_clip"},
        {name="door_0-door_physics_clip",filter="door_0-weighted_cube_filter"},
        {name="InstanceAuto22-sphere_clip"},
    ],
    sp_a4_speed_tb_catch=[
        {name="fizzler_moving"},
        {name="fizzler_moving"},
        {name="box_stoppers"},
        {name="box_stoppers"},
        {name="fizzler_moving"},
        {name="exit_door-door_physics_clip",filter="exit_door-weighted_cube_filter"},
        {name="@exit_elevator_cleanser"},
    ],
    sp_a4_laser_platform=[
        {name="box_dropper-cube_dropper_box_reenter_clip"},
        {name="entrance_door-door_physics_clip",filter="entrance_door-weighted_cube_filter"},
        {name="@exit_elevator_cleanser"},
    ],
    sp_a3_03=[
        {name="silent_fizzler"},
        {origin=Vector(-3633.11,1345.33,-2480)},
    ],
    sp_a4_finale4=[
        {origin=Vector(0,-140,-1348)},
    ],
    sp_a2_laser_intro=[
        {name="door_0-door_physics_clip",filter="door_0-weighted_cube_filter"},
        {name="@exit_door-door_physics_clip",filter="@exit_door-weighted_cube_filter"}
    ],
    sp_a4_laser_catapult=[
        {name="func_clip_vphysics_block_cubes_1"},
        {name="@exit_door-door_physics_clip",filter="@exit_door-weighted_cube_filter"},
        {name="@entry_door-door_physics_clip",filter="@entry_door-weighted_cube_filter"},
        {name="@exit_elevator_cleanser"},
    ],
    sp_a2_turret_intro=[
        {name="fun_nel"},
        {name="door_0-door_physics_clip",filter="door_0-weighted_cube_filter"},
        {name="@exit_door-door_physics_clip",filter="@exit_door-weighted_cube_filter"}
    ],
    sp_a4_finale1=[
        {origin=Vector(-10691.3,-2048,143.63)},
        {origin=Vector(-12832,-2792.1,-108)},
        {name="entrance_door-door_physics_clip",filter="entrance_door-weighted_cube_filter"},
    ],
    sp_a4_intro=[
        {name="@exit_elevator_cleanser"},
        {name="@exit_elevator_cleanser"},
        {name="button_box_brush",filter="cube_bot_filter"},
        {name="@exit_elevator_cleanser"},
        {name="@exit_door1-door_physics_clip",filter="@exit_door1-weighted_cube_filter"},
        {name="@entrance_door1-door_physics_clip",filter="@entrance_door1-weighted_cube_filter"},
        {name="@exit_door-door_physics_clip",filter="@exit_door-weighted_cube_filter"},
        {name="door_0-door_physics_clip",filter="door_0-weighted_cube_filter"},
        {name="@exit_door2-door_physics_clip",filter="@exit_door2-weighted_cube_filter"},
        {name="@entrance_door2-door_physics_clip",filter="@entrance_door2-weighted_cube_filter"},
        {name="@exit_elevator_cleanser"},
    ],
    sp_a4_finale3=[
        {name="AutoInstance1-@exit_elevator_cleanser"},
        {name="AutoInstance1-@exit_elevator_cleanser1"},
        {name="@exit_elevator_cleanser"},
        {origin=Vector(0,0,0)},
    ],
    sp_a4_tb_wall_button=[
        {name="pre_move_cleanser"},
        {name="pre_move_cleanser"},
        {name="pre_move_cleanser"},
        {name="door_0-door_physics_clip",filter="door_0-weighted_cube_filter"},
        {name="@exit_door-door_physics_clip",filter="@exit_door-weighted_cube_filter"},
        {name="@exit_elevator_cleanser"},
    ],
    sp_a1_intro4=[
        {name="box_dropper_phys_clip"},
        {name="door_1-door_physics_clip",filter="door_1-weighted_cube_filter"},
        {name="door_2-door_physics_clip",filter="door_2-weighted_cube_filter"},
        {name="door_0-door_physics_clip",filter="door_0-weighted_cube_filter"},
        {name="just_enough_door_for_the_job-door_physics_clip",filter="just_enough_door_for_the_job-weighted_cube_filter"},
        {name="box_dropper-cube_dropper_box_reenter_clip"},
    ],
    sp_a3_transition01=[
        {name="AutoInstance1-$cleanser_name"},
        {origin=Vector(-2113.33,-128.11,-4096)},
    ],
    sp_a3_speed_ramp=[
        {origin=Vector(-1344.11,-251.67,448.25)},
        {origin=Vector(-1184.5,384,448)},
        {origin=Vector(1166.67,-640.11,448)},
    ],
    sp_a3_speed_flings=[
        {origin=Vector(465.33,1152.11,96)},
    ],
    sp_a2_ricochet=[
        {name="cube_safety_clip_brush"},
        {name="cube_clip_brushes"},
        {name="cube_clip_brushes"},
        {name="upper_gate_clip_brush"},
        {name="lower_gate_clip_brush"},
        {name="wall_repair_clip_brush"},
        {name="cube_clip_brushes"},
        {name="cube_clip_brushes"},
        {name="midroom_upper_panel_1-airlock_lower_panel_1_physblocker"},
        {name="midroom_lower_panel_1-airlock_lower_panel_1_physblocker"},
        {name="@exit_door-door_physics_clip",filter="@exit_door-weighted_cube_filter"},
        {name="door_0-door_physics_clip",filter="door_0-weighted_cube_filter"},
        {name="reflecto_cube_dropper-cube_dropper_box_reenter_clip"},
        {name="midroom_upper_panel_1-airlock_lower_panel_1_physblocker"},
        {name="midroom_lower_panel_1-airlock_lower_panel_1_physblocker"}
    ],
    sp_a2_laser_over_goo=[
        {name="@exit_door-door_physics_clip",filter="@exit_door-weighted_cube_filter"},
        {name="door_1-door_physics_clip",filter="door_1-weighted_cube_filter"}
    ],
    sp_a2_sphere_peek=[
        {name="HACK_clip"},
        {name="HACK_clip"},
        {name="HACK_clip"},
        {name="HACK_clip"},
        {name="door_0-door_physics_clip",filter="door_0-weighted_cube_filter"},
        {name="@exit_door-door_physics_clip",filter="@exit_door-weighted_cube_filter"}
    ],
    sp_a2_fizzler_intro=[
        {origin=Vector(128,-432,64)},
        {name="cube_dropper-cube_dropper_box_reenter_clip"},
        {name="@exit_door-door_physics_clip",filter="@exit_door-weighted_cube_filter"},
        {name="door_0-door_physics_clip",filter="door_0-weighted_cube_filter"}
    ],
    sp_a3_jump_intro=[
        {name="AutoInstance1-$cleanser_name"},
        {name="AutoInstance1-$cleanser_name"},
        {name="AutoInstance1-$cleanser_name"},
        {name="AutoInstance1-$cleanser_name"},
        {name="room_2_cube_dropper_1_physics_clip"},
        {origin=Vector(-1264,1152,1376)},
        {origin=Vector(-1264,1152,1248)},
        {origin=Vector(-737.33,2079.89,1572)},
    ],
    sp_a3_end=[
        {name="AutoInstance1-$cleanser_name"},
        {name="@exit_elevator_cleanser"},
    ],
    sp_a2_trust_fling=[
        {name="box_collision",filter="cube_filter"},
        {name="door_0-door_physics_clip",filter="door_0-weighted_cube_filter"},
        {name="door_52-door_physics_clip",filter="door_52-weighted_cube_filter"},
    ],
    sp_a2_pit_flings=[
        {name="tilex9_cube_clip",filter="filter_weighted_cube"},
        {name="walltunnel_1_Cover_clip"},
        {name="walltunnel_1_Cover_clip"},
        {name="cube_elevator_clip"},
        {name="physobject_floor_clip",filter="filter_weighted_cube"},
        {name="walltunnel_1_Cover_clip"},
        {name="walltunnel_1_Cover_clip"},
        {name="ramp_cube_clip",filter="filter_weighted_cube"},
        {name="box_pre_blocker"},
        {name="door_0-door_physics_clip",filter="door_0-weighted_cube_filter"},
        {name="room_2_exit_door-door_physics_clip",filter="room_2_exit_door-weighted_cube_filter"},
        {name="cube_dropper-cube_dropper_box_reenter_clip"},
        {name="@exit_elevator_cleanser"},
    ],
    sp_a2_turret_blocker=[
        {name="cheat_protection"},
        {name="@exit_door-door_physics_clip",filter="@exit_door-weighted_cube_filter"},
        {name="door_0-door_physics_clip",filter="door_0-weighted_cube_filter"}
    ],
    sp_a3_crazy_box=[
        {origin=Vector(1536,-1463.5,96)},
        {origin=Vector(99.67,-1280.11,1596.25)},
        {origin=Vector(1796,-1415.67,520)},
        {origin=Vector(1536,-1463.5,176)},
        {origin=Vector(2239.89,-779.67,64.25)},
        {origin=Vector(640.11,110.67,1984)},
        {origin=Vector(2239.89,-779.67,-63.75)},
    ],
    sp_a2_intro=[
        {name="impact_phys_clip"},
        {name="door_0-door_physics_clip",filter="door_0-weighted_cube_filter"}
    ],
    sp_a2_triple_laser=[
        {name="door_0-door_physics_clip",filter="door_0-weighted_cube_filter"},
        {name="@exit_door-door_physics_clip",filter="@exit_door-weighted_cube_filter"}
    ],
    sp_a2_bridge_the_gap=[
        {name="@exit_door-door_physics_clip",filter="@exit_door-weighted_cube_filter"},
        {name="cube_dropper-cube_dropper_box_reenter_clip"},
        {name="door_0-door_physics_clip",filter="door_0-weighted_cube_filter"}
    ],
    sp_a4_stop_the_box=[
        {origin=Vector(543,320,544)},
        {origin=Vector(543,320,800)},
        {origin=Vector(543,320,928)},
        {origin=Vector(543,320,1056)},
        {origin=Vector(543,320,672)},
        {name="@exit_door-door_physics_clip",filter="@exit_door-weighted_cube_filter"},
        {name="door_0-door_physics_clip",filter="door_0-weighted_cube_filter"},
        {name="@exit_elevator_cleanser"},
    ],
    sp_a2_bts1=[
        {name="jailbreak_chamber_unlit-portal_fizzler_1"},
        {name="jailbreak_chamber_unlit-cube_blocker_brush",filter="jailbreak_chamber_unlit-cube_filter"},
        {name="jailbreak_chamber_unlit-cube_blocker_brush",filter="jailbreak_chamber_unlit-cube_filter"},
        {name="jailbreak_chamber_unlit-cube_blocker_brush",filter="jailbreak_chamber_unlit-cube_filter"},
        {name="jailbreak_chamber_unlit-cube_blocker_brush",filter="jailbreak_chamber_unlit-cube_filter"},
        {name="jailbreak_chamber_unlit-portal_fizzler_2"},
        {name="jailbreak_chamber_lit-cube_blocker_brush",filter="jailbreak_chamber_lit-cube_filter"},
        {name="jailbreak_chamber_lit-cube_blocker_brush",filter="jailbreak_chamber_lit-cube_filter"},
        {name="jailbreak_chamber_lit-cube_blocker_brush",filter="jailbreak_chamber_lit-cube_filter"},
        {name="jailbreak_chamber_lit-cube_blocker_brush",filter="jailbreak_chamber_lit-cube_filter"},
        {name="jailbreak_chamber_lit-power_loss_portal_fizzle"},
        {name="chamber_door-door_physics_clip",filter="chamber_door-weighted_cube_filter"},
        {name="pre_solved_chamber-box_dissolver"},
        {name="pre_solved_chamber-door_1-door_physics_clip",filter="pre_solved_chamber-door_1-weighted_cube_filter"},
        {name="pre_solved_chamber-box_dropper_01-cube_dropper_box_reenter_clip"},
    ],
    sp_a1_intro1=[
        {name="exit_door_cube_clip",filter="cube_filter"},
        {name="cube_clip"},
        {name="door_1-door_physics_clip",filter="door_1-weighted_cube_filter"},
        {name="@exit_door-door_physics_clip",filter="@exit_door-weighted_cube_filter"}
    ],
    sp_a3_portal_intro=[
        {origin=Vector(256,-992,-1168)},
        {origin=Vector(2411.67,-96.11,-2559.75)},
        {origin=Vector(2288.33,-95.89,607.717)},
        {origin=Vector(2407.67,-1120.11,-2879.75)},
        {origin=Vector(2432.11,1203.67,-1983.75)},
        {origin=Vector(863.89,1584.33,-1631.75)},
    ],
    sp_a2_laser_relays=[
        {name="door_0-door_physics_clip",filter="door_0-weighted_cube_filter"},
        {name="@exit_door-door_physics_clip",filter="@exit_door-weighted_cube_filter"}
    ],
    sp_a2_laser_chaining=[
        {name="floor_arm_collision"},
        {name="door_0-door_physics_clip",filter="door_0-weighted_cube_filter"},
        {name="@exit_door-door_physics_clip",filter="@exit_door-weighted_cube_filter"}
    ],
    sp_a2_pull_the_rug=[
        {name="box_restarter",filter="box1_filter"},
        {name="door_0-door_physics_clip",filter="door_0-weighted_cube_filter"},
        {name="@exit_door-door_physics_clip",filter="@exit_door-weighted_cube_filter"}
    ],
    sp_a3_bomb_flings=[
        {origin=Vector(128,-528,688)},
        {origin=Vector(128,-528,549.5)},
        {origin=Vector(128,-528,826.5)},
        {origin=Vector(-256.11,1633.33,640)},
    ],
}

//switch because fizzlers have to be difficult with enabling/disabling and the names not wanting to work, fuck fizzlers too. i understand why this was scrapped originally
function FizzlerTrigger() {

    EntFire("cubecore_cube", "AddOutput", "OnPhysGunDrop @exit_elevator_cleanser:Enable::0:-1",0.5);
    EntFire("cubecore_cube", "AddOutput", "OnPlayerPickup @exit_elevator_cleanser:Disable::0:-1",0.5);

    switch(GetMapName()) {
        case "sp_a1_intro4":
            EntFire("cubecore_cube", "AddOutput", "OnPhysGunDrop fizzler_brush:Enable::0:-1",0);
            EntFire("cubecore_cube", "AddOutput", "OnPlayerPickup fizzler_brush:Disable::0:-1",0);
        case "sp_a1_intro6":
            EntFire("cubecore_cube", "AddOutput", "OnPhysGunDrop InstanceAuto4-cleanser1-InstanceAuto4-cleanser:Enable::0:-1",0);
            EntFire("cubecore_cube", "AddOutput", "OnPlayerPickup InstanceAuto4-cleanser1-InstanceAuto4-cleanser:Disable::0:-1",0);
    }
}

//im scared im gonna have to add another switch/case func that decides where to spawn the cube if it dies per level
//if i do, i can have a condition/position combo, where if when the cube dies condition A is met, it goes to dropper A, otherwise it goes to dropper B.
//oh fuck i might have to hard code some droppers for levels so the cube has a place to respawn

AddModeFunctions("cubecore", CubeCorePostSpawn, CubeCoreLoad, CubeCoreUpdate, CubeCorePrecache)
