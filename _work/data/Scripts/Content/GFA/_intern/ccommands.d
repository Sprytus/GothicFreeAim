/*
 * Definition of all console commands
 *
 * Gothic Free Aim (GFA) v1.0.0-beta.22 - Free aiming for the video games Gothic 1 and Gothic 2 by Piranha Bytes
 * Copyright (C) 2016-2017  mud-freak (@szapp)
 *
 * This file is part of Gothic Free Aim.
 * <http://github.com/szapp/GothicFreeAim>
 *
 * Gothic Free Aim is free software: you can redistribute it and/or
 * modify it under the terms of the MIT License.
 * On redistribution this notice must remain intact and all copies must
 * identify the original author.
 *
 * Gothic Free Aim is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * MIT License for more details.
 *
 * You should have received a copy of the MIT License along with
 * Gothic Free Aim.  If not, see <http://opensource.org/licenses/MIT>.
 */


/*
 * Console function to enable/disable debug output to zSpy. This function is registered as console command.
 */
func string GFA_DebugPrint(var string _) {
    GFA_DEBUG_PRINT = !GFA_DEBUG_PRINT;
    if (GFA_DEBUG_PRINT) {
        return "Debug outputs on.";
    } else {
        return "Debug outputs off.";
    };
};


/*
 * Console function to enable/disable trace ray debug output. This function is registered as console command.
 * When enabled, the trace ray is continuously drawn, as well as the nearest intersection with it.
 */
func string GFA_DebugTraceRay(var string _) {
    if (!Hlp_IsValidHandle(GFA_DebugTRTrj)) {
        GFA_DebugTRTrj = DrawLineAddr(0, zCOLOR_GREEN);
        HideLine(GFA_DebugTRTrj);
    };

    if (!Hlp_IsValidHandle(GFA_DebugTRBBox)) {
        GFA_DebugTRBBox = DrawBBoxAddr(0, zCOLOR_GREEN);
        HideBBox(GFA_DebugTRBBox);
    };

    if (!Hlp_IsValidHandle(GFA_DebugTRBBoxVob)) {
        GFA_DebugTRBBoxVob = DrawBBoxAddr(0, zCOLOR_GREEN);
        HideBBox(GFA_DebugTRBBoxVob);
    };

    if (!LineVisible(GFA_DebugTRTrj)) && (!BBoxVisible(GFA_DebugTRBBox)) && (!BBoxVisible(GFA_DebugTRBBoxVob)) {
        ShowBBox(GFA_DebugTRTrj);
        ShowBBox(GFA_DebugTRBBox);
        ShowBBox(GFA_DebugTRBBoxVob);
        return "Debug trace ray on.";
    } else {
        HideBBox(GFA_DebugTRTrj);
        HideBBox(GFA_DebugTRBBox);
        HideBBox(GFA_DebugTRBBoxVob);
        return "Debug trace ray off.";
    };
};


/*
 * Console function to enable/disable trace ray debug output. This function is registered as console command.
 * When enabled, the trajectory of the projectile is continuously drawn.
 */
func string GFA_DebugTrajectory(var string _) {
    if (!Hlp_IsValidHandle(GFA_DebugCollTrj)) {
        GFA_DebugCollTrj = DrawLineAddr(_@(GFA_CollTrj), zCOLOR_RED);
    } else {
        ToggleLine(GFA_DebugCollTrj);
    };

    if (LineVisible(GFA_DebugCollTrj)) {
        return "Debug projectile trajectory on.";
    } else {
        return "Debug projectile trajectory off.";
    };
};


/*
 * Console function to enable/disable weak spot debug output. This function is registered as console command.
 * When enabled, the defined weak spot of the last shot NPC is visualized by a bounding box or oriented bounding box.
 */
func string GFA_DebugWeakspot(var string _) {
    if (!Hlp_IsValidHandle(GFA_DebugWSBBox)) {
        GFA_DebugWSBBox = DrawBBoxAddr(0, zCOLOR_RED);
        HideBBox(GFA_DebugWSBBox);
    };

    if (!Hlp_IsValidHandle(GFA_DebugWSOBBox)) {
        GFA_DebugWSOBBox = DrawOBBoxAddr(0, zCOLOR_RED);
        HideOBBox(GFA_DebugWSOBBox);
    };

    if (!BBoxVisible(GFA_DebugWSBBox) && (!OBBoxVisible(GFA_DebugWSOBBox))) {
        ShowBBox(GFA_DebugWSBBox);
        ShowOBBox(GFA_DebugWSOBBox);
        if (!LineVisible(GFA_DebugCollTrj)) {
            var string s; s = GFA_DebugTrajectory("");
        };
        return "Debug weak spot on.";
    } else {
        HideBBox(GFA_DebugWSBBox);
        HideOBBox(GFA_DebugWSOBBox);
        return "Debug weak spot off.";
    };
};


/*
 * Console function to show free aiming shooting statistics. This function is registered as console command.
 * When entered in the console, the current shooting statistics are displayed as the console output.
 */
func string GFA_GetShootingStats(var string args) {
    if (!GFA_ACTIVE) || (!(GFA_Flags & GFA_RANGED)) {
        return "Shooting statistics not available. (Requires free aiming for ranged weapons)";
    };

    // Prevent execution if 'reset' command is called
    if (!Hlp_StrCmp(args, "")) && (!Hlp_StrCmp(args, " ")) {
        return "";
    };

    var int s; s = SB_New();
    SB("Total shots taken: ");
    SBi(GFA_StatsShots);
    SBc(13); SBc(10);

    SB("Shots on target: ");
    SBi(GFA_StatsHits);
    SBc(13); SBc(10);

    SB("Personal accuracy: ");
    var int pAccuracy;
    if (!GFA_StatsShots) {
        // Division by zero
        pAccuracy = FLOATNULL;
    } else {
        pAccuracy = mulf(fracf(GFA_StatsHits, GFA_StatsShots), FLOAT1C);
    };
    SB(STR_Prefix(toStringf(pAccuracy), 4));
    SB("%");

    if (GFA_Flags & GFA_CRITICALHITS) {
        SBc(13); SBc(10);
        SB("Critical hits: ");
        SBi(GFA_StatsCriticalHits);
    };

    var string ret; ret = SB_ToString();
    SB_Destroy();

    return ret;
};


/*
 * Console function to reset free aiming shooting statistics. This function is registered as console command.
 * When entered in the console, the current shooting statistics are reset to zero.
 */
func string GFA_ResetShootingStats(var string _) {
    GFA_StatsShots = 0;
    GFA_StatsHits = 0;
    GFA_StatsCriticalHits = 0;
    return "Shooting statistics reset.";
};


/*
 * Console function to show GFA version. This function is registered as console command.
 * When entered in the console, the current GFA version is displayed as the console output.
 */
func string GFA_GetVersion(var string _) {
    return GFA_VERSION;
};


/*
 * Console function to show GFA license. This function is registered as console command.
 * When entered in the console, the GFA license information is displayed as the console output.
 */
func string GFA_GetLicense(var string _) {
    var int s; s = SB_New();
    SB(GFA_VERSION);
    SB(", Copyright ");
    SBc(169 /* (C) */);
    SB(" 2016-2017  mud-freak (@szapp)");
    SBc(13); SBc(10);

    SB("<http://github.com/szapp/GothicFreeAim>");
    SBc(13); SBc(10);

    SB("Released under the MIT License.");
    SBc(13); SBc(10);

    SB("For more details see <http://opensource.org/licenses/MIT>.");

    var string ret; ret = SB_ToString();
    SB_Destroy();

    return ret;
};


/*
 * Console function to show GFA info. This function is registered as console command.
 * When entered in the console, the GFA config is displayed as the console output.
 */
func string GFA_GetInfo(var string _) {
    const string onOff[2] = {"OFF", "ON"};

    var int s; s = SB_New();
    SB(GFA_VERSION);
    SBc(13); SBc(10);

    SB("Free aiming: ");
    SB(MEM_ReadStatStringArr(onOff, GFA_ACTIVE > 0));
    if (GFA_ACTIVE) {
        SB(" for");
        if (GFA_Flags & GFA_RANGED) {
            SB(" (ranged)");
        };
        if (GFA_Flags & GFA_SPELLS) {
            SB(" (spells)");
        };

        SB(". Strafing: ");
        SB(MEM_ReadStatStringArr(onOff, GFA_STRAFING > 0));

        SB(". Focus update every ");
        SBi(GFA_AimRayInterval);
        SB(" ms");
    };
    SBc(13); SBc(10);

    SB("Reusable projectiles: ");
    SB(MEM_ReadStatStringArr(onOff, (GFA_Flags & GFA_REUSE_PROJECTILES) > 0));
    SBc(13); SBc(10);

    SB("Custom collision behaviors: ");
    SB(MEM_ReadStatStringArr(onOff, (GFA_Flags & GFA_CUSTOM_COLLISIONS) > 0));
    SBc(13); SBc(10);

    SB("Criticial hit detection: ");
    SB(MEM_ReadStatStringArr(onOff, (GFA_Flags & GFA_CRITICALHITS) > 0));

    var string ret; ret = SB_ToString();
    SB_Destroy();

    return ret;
};
