--[[------------------------------------------------------------------------------
 *  Copyright (C) Fluffy(76561197976769128 - STEAM_0:0:8251700) - All Rights Reserved
 *  Unauthorized copying of this file, via any medium is strictly prohibited
 *  Proprietary and confidential
--]]------------------------------------------------------------------------------

Sublime.Languages["en"] = 
{
    -- Main
        this_language = "English",
    --
    
    -- Home
        home_level              = "LEVEL",
        home_total              = "TOTAL GAINED LEVELS",
        home_experience         = "EXPERIENCE",
        home_total_experience   = "TOTAL EXPERIENCE GAINED",
        home_available_points   = "AVAILABLE ABILITY POINTS",
        home_spent_points       = "SPENT ABILITY POINTS",
        home_strength           = "STRENGTH",
        home_strength_total     = "TOTAL ABILITY POINTS SPENT ON STRENGTH",
        home_agility            = "AGILITY",
        home_agility_total      = "TOTAL ABILITY POINTS SPENT ON AGILITY",
        home_intellect          = "INTELLECT",
        home_intellect_total    = "TOTAL ABILITY POINTS SPENT ON INTELLECT",
        home_leaderboards_rank  = "LEADERBOARDS RANK",
        home_personal_stats     = "PERSONAL STATS",
        home_global_stats       = "GLOBAL STATS",
        home_home               = "Home",
        home_players            = "Players",
        home_leaderboards       = "Leaderboards",
        home_skills             = "Skills",
        home_options            = "Options",
    --

    -- Players
        players_players     = "Players",
        players_online      = "Players Online: %i/%i";
    --
    
    -- Leaderboards
        leaderboards_previous       = "Previous Page",
        leaderboards_next           = "Next Page",
        leaderboards_player         = "Player",
        leaderboards_level          = "Level",
        leaderboards_experience     = "Experience",
        leaderboards_t_experience   = "Total Experience",
    --

    -- Skills
        skills_strength     = "Physical Attributes",
        skills_intellect    = "Intellect",
        skills_agility      = "Agility",
        skills_skills       = "Skills",
        skills_available    = "You have %i skill points to use",
        skills_invalid      = "Invalid",
        skills_cant_afford  = "You don't have any Skill Points to use. Try leveling up first.",
        skills_are_you_sure = "Are you sure?",
        skills_unlock_conf  = "Are you sure you want to unlock the next step of this skill?",
        skills_unlock_fail  = "You have to unlock the skills prior to this in order to be able to unlock this.",
        skills_enabled      = "Should the skills system be enabled? Def. Yes",
    --

    -- Options
        options_options = "Options",
        reset_database = "Reset Database",
    --

    -- Players
        players_name        = "Name",
        players_level       = "Level",
        players_experience  = "Experience",
    --

    -- Notifications
        notification_accept     = "Accept",
        notification_decline    = "Decline",

        notification_give_level             = "Give Levels",
        notification_give_level_desc        = "How many levels do you want to give?",

        notification_take_level             = "Take Levels",
        notification_take_level_desc        = "How many levels do you want to take? This doesn't take skill points.",

        notification_give_skill             = "Give skill points",
        notification_give_skill_desc        = "How many skill points do you want to give?",

        notification_take_skill             = "Take skill points",
        notification_take_skill_desc        = "How many skill points do you want to take?",

        notification_give_experience        = "Give experience",
        notification_give_experience_desc   = "You can only give whatever the person is missing for a level or less.",

        notification_reset_experience       = "Reset experience",
        notification_reset_experience_desc  = "This sets his XP earned to 0.",
        

        notification_invalid_character_title    = "Invalid character",
        notification_invalid_character_des      = "This field can only hold numbers.",
        notification_player_invalid_title       = "Invalid player",
        notification_player_invalid_desc        = "It seems that this player has left the server.",
        notification_max_level_title            = "Reached Max",
        notification_max_level_desc             = "The max levels you can give this person is %s else their level would be beyond max.",
        notification_invalid_value_title        = "Forbidden value",
        notification_invalid_value_desc         = "The number given must be greater than 0. If you want to take levels then use the take option instead.",
        notification_success_title              = "Request success",
        notification_success_desc               = "Your request to change %s's data was accepted.",
    --

    -- Client Settings
        client_settings     = "Client Settings",
        client_saved        = "Saved Client Settings",
        client_save         = "Save Client Settings",
        client_default      = "Reset Client Settings",
        client_change_key   = "Change Menu Key",
        client_press_any    = "PRESS ANY KEY",
        client_other_debug  = "Should we enable debug messages in the console for your client?",
        client_hud_display  = "Should we display Sublime Levels HUD Elements?",
        client_hud_blur     = "Should we use blur around the menu?",
        client_hud_pos      = "Change the position of the HUD",
        client_hud_bar      = "Should we use bar hud for the xp instead of circular?",
        client_xp_display   = "Should we give chat notifications when we get experience?",
        menu_open           = "What should the key to open the Sublime Levels menu be? def. F6",
        blur                = "Should we use blur around the Sublime Levels menu? def. Yes",
        hud_y               = "What should the Y position of the HUD be?",
        hud_x               = "What should the X position of the HUD be?",
        hud_bar             = "Should we use the bar version of the HUD? def. No.",
        display             = "Should we use the Sublime Levels HUD at all? def. Yes",
        debug_enabled       = "Should we enable the debug messages for the client? def. No",

        experience_notifications    = "Should there be experience notifications in the chat? def. Yes",
        hud_circle                  = "Should we use the Circle version of the HUD? def. No.",
        hud_modern                  = "Should we use the Modern version of the HUD? def. Yes.",
    --

    -- Server Settings
        server_settings                     = "Server Settings",
        server_save                         = "Save Server Settings",
        server_default                      = "Reset Server Settings",
        server_access_denied                = "SERVER SIDE ACCESS DENIED",
        server_chat_command                 = "Change the chat command for the menu. Prefix ! and / is already included.",
        server_kills_npc                    = "How much XP should the player receive after killing a NPC?",
        server_kills_player                 = "How much XP should the player receive after killing another player?",
        server_kills_headshot               = "How much more XP should the player receive after killing something with a headshot?",
        server_other_vip                    = "How much more XP should VIP players get? <This applies for everything>",
        server_other_max                    = "What is the maximum level a player can reach?",
        server_other_base_xp                = "What should the base experience be for all players? <The more this is, the harder it is to level>",
        server_other_base_xp_mod            = "What should the base experience modifier be for all players? <The more this is, the harder it is to level>",
        server_other_debug                  = "Should we enable debug messages in the console for the server?",
        server_other_xp_for_playing         = "How much experience should we get just for playing on the server?",
        server_other_xp_when                = "How frequent should we receive experience just for playing? These are in seconds.",
        server_other_prefix                 = "What should the prefix for the level/xp notifications be?",
        server_other_disable_notifications  = "Disable client chat notifications entierly?",

        server_ttt                          = "Trouble in terrorist town",
        server_darkrp                       = "DarkRP",
        server_murder                       = "Murder",
        server_other                        = "Other",
        server_kills                        = "Kills",
        
        npc_on_kill_experience                  = "How much experience should players receive on killing a NPC? Def. 100",
        player_on_kill_experience               = "How much experience should players receive on killing a player? Def.150",
        headshot_modifier                       = "What should the headshot modifier be? Example: 100 * 1.2 = 120. Def. 1.2",
        vip_modifier                            = "How much extra experience should VIP players get? Def. 2",
        chat_command                            = "Whats hould the chat command for opening the menu be?",
        max_level                               = "What should the max level be? Def. 99",
        xp_for_playing_when                     = "How often should players receieve experience just for playing, in seconds? Def. 600",
        xp_for_playing                          = "How much experience should players receive for just playing on the server? Def. 25",
        debug_enabled                           = "Should we enable debug mode serverside? Def. No",
        sound_on_level                          = "What sound should we play for the player when they level up?",
        sound_on_xp                             = "What sound should we play for players when they receive experience?",
        disable_notifications                   = "Should we globally disable notifications(Notifications, sounds, etc)? Def. No.",
        chat_prefix                             = "Chat prefix when receiving notifications? Def. [SublimeLevels]",
        lottery_winner                          = "How much experience should players who win the lottery get? Def. 2000",
        hitman_completed                        = "How much experience should hitmen get for completing their hit? Def. 300",
        player_arrested                         = "How much experience should officers get when they arrest someone? Def. 75",
        player_taxed                            = "How much experience should players get when they're taxed? Def. 25",
        killing_traitors                        = "How much experience should players get when they kill a traitor? Def. 200",
        killing_innocent                        = "How much experience should players get when they kill an innocent? Def. 50",
        killing_detective                       = "How much experience should players get when they kill a detective? Def. 200",
        traitor_winners                         = "How much experience should traitors get when they win the round? Def. 200",
        innocent_winners                        = "How much experience should the innocent get when they win the round? Def. 200",
        draw                                    = "How much experience should players get when the round ended in a draw? Def. 50",
        should_innocent_get_xp_when_dead        = "Should innocent get experience when they're dead? Def. No",
        should_traitor_get_xp_when_dead         = "Should traitors get experience when they're dead? Def. Yes",
        should_spectators_get_xp_when_roundend  = "Should spectators get experience when round ends? Def. No",
        murderer_winners                        = "How much should experience should the murderer get when he wins the round? Def. 500",
        bystander_winners                       = "How much experience should bystanders get when they win the round? Def. 250",
        needed_on_server_before_xp              = "How many players are needed on the server before giving experience? Def. 4",
        should_broadcast_levelup                = "Should we broadcast the players level up to other players? Def. Yes",


        server_skills_strength_en   = "Should we enable the strength tree?",

        server_darkrp_lottery       = "How much XP should we give the winner of the lottery?",
        server_darkrp_hitman        = "How much XP should we give the hitman for successfully completing a hit?",
        server_darkrp_arrested      = "How much XP should we give police officers who arrest people?",
        server_darkrp_taxed         = "How much XP should a taxed player receive upon being taxed?",

        server_ttt_traitor_win      = "How much XP should the traitors get upon winning a round?",
        server_ttt_innocent_win     = "How much XP should the innocent get upon winning a round?",
        server_ttt_draw_win         = "How much XP should everyone receive if the game ends in a draw?",

    --
}