--Translation from: https://gist.github.com/SuperCALIENTITO/7a0dcb417e966db6a934330d19b08ef1
--By: https://www.gmodstore.com/users/76561198348715045
Sublime.Languages["es"] = 
{
    -- Main
        this_language = "Español",
    --
    
    -- Home
        home_level              = "NIVEL",
        home_total              = "NIVELES TOTALES GANADOS",
        home_experience         = "EXPERIENCIA",
        home_total_experience   = "EXPERIENCIA TOTAL GANADA",
        home_available_points   = "PUNTOS DE HABILIDAD DISPONIBLES",
        home_spent_points       = "PUNTOS DE HABILIDAD GASTADOS",
        home_strength           = "FUERZA",
        home_strength_total     = "PUNTOS DE HABILIDAD TOTALES GASTADOS EN FUERZA",
        home_agility            = "AGILIDAD",
        home_agility_total      = "PUNTOS DE HABILIDAD TOTALES GASTADOS EN AGILIDAD",
        home_intellect          = "INTELIGENCIA",
        home_intellect_total    = "PUNTOS DE HABILIDAD TOTALES GASTADOS EN INTELIGENCIA",
        home_leaderboards_rank  = "RANKING DE CLASIFICACIONES",
        home_personal_stats     = "ESTADÍSTICAS PERSONALES",
        home_global_stats       = "ESTADÍSTICAS GLOBALES",
        home_home               = "Inicio",
        home_players            = "Jugadores",
        home_leaderboards       = "Clasificaciones",
        home_skills             = "Habilidades",
        home_options            = "Opciones",
    --

    -- Players
        players_players = "Jugadores",
        players_online = "Jugadores en línea: %i/%i";
    --
    
    -- Leaderboards
        leaderboards_previous       = "Página anterior",
        leaderboards_next           = "Página siguiente",
        leaderboards_player         = "Jugador",
        leaderboards_level          = "Nivel",
        leaderboards_experience     = "Experiencia",
        leaderboards_t_experience   = "Experiencia total",
        leaderboards_open_profile   = "Open Profile",
        leaderboards_copy_steamid   = "Copy SteamID64",
        leaderboards_set_level      = "Set Level",
        leaderboards_set_level_desc = "Set the level of the player to the given value.",
        leaderboards_give_skill     = "Give Skill Points",
        leaderboards_take_skill     = "Take Skill Points",
        leaderboards_give_exp       = "Give Experience",
        leaderboards_reset_user     = "Reset user data",
    --

    -- Skills
        skills_strength     = "Atributos físicos",
        skills_intellect    = "Inteligencia",
        skills_agility      = "Agilidad",
        skills_skills       = "Habilidades",
        skills_available    = "Tienes %i puntos de habilidad para usar",
        skills_invalid      = "No válido",
        skills_cant_afford  = "No tienes puntos de habilidad para usar. Primero prueba a subir de nivel.",
        skills_are_you_sure = "¿Estás seguro?",
        skills_unlock_conf  = "¿Estás seguro de que quieres desbloquear el siguiente paso de esta habilidad?",
        skills_unlock_fail  = "Tienes que desbloquear las habilidades anteriores a esta para poder desbloquear esta.",
        skills_enabled      = "¿Debería estar habilitado el sistema de habilidades? (Por defecto sí)",
    --

    -- Options
        options_options = "Opciones",
        reset_database = "Reiniciar base de datos",
    --

    -- Players
        players_name        = "Nombre",
        players_level       = "Nivel",
        players_experience  = "Experiencia",
    --

    -- Notifications
        notification_accept     = "Aceptar",
        notification_decline    = "Rechazar",

        notification_give_level             = "Dar niveles",
        notification_give_level_desc        = "¿Cuántos niveles quieres dar?",

        notification_take_level             = "Tomar niveles",
        notification_take_level_desc        = "¿Cuántos niveles quieres tomar? Esto no toma puntos de habilidad.",

        notification_give_skill             = "Dar puntos de habilidad",
        notification_give_skill_desc        = "¿Cuántos puntos de habilidad quieres dar?",

        notification_take_skill             = "Tomar puntos de habilidad",
        notification_take_skill_desc        = "¿Cuántos puntos de habilidad quieres tomar?",

        notification_give_experience        = "Dar experiencia",
        notification_give_experience_desc   = "Sólo puedes dar lo que la persona le falta para subir de nivel o menos.",

        notification_reset_experience       = "Reiniciar experiencia",
        notification_reset_experience_desc  = "Esto establece la experiencia ganada en 0.",
        

        notification_invalid_character_title    = "Carácter no válido",
        notification_invalid_character_des      = "Este campo sólo puede contener números.",
        notification_player_invalid_title       = "Jugador no válido",
        notification_player_invalid_desc        = "Parece que este jugador ha dejado el servidor.",
        notification_max_level_title            = "Llegó al máximo",
        notification_max_level_desc             = "Los niveles máximos que puedes dar a esta persona son %s, de lo contrario el nivel estaría más allá del máximo.",
        notification_invalid_value_title        = "Valor prohibido",
        notification_invalid_value_desc         = "El número dado debe ser mayor que 0. Si quieres tomar niveles, usa la opción de tomar en su lugar.",
        notification_success_title              = "Solicitud exitosa",
        notification_success_desc               = "Tu solicitud para cambiar los datos de %s fue aceptada.",
    --

    -- Client Settings
        client_settings         = "Ajustes del cliente",
        client_saved            = "Ajustes del cliente guardados",
        client_save             = "Guardar ajustes del cliente",
        client_default          = "Reiniciar ajustes del cliente",
        client_change_key       = "Cambiar la clave del menú",
        client_press_any        = "PULSE CUALQUIER TECLA",
        client_other_debug      = "¿Deberíamos habilitar mensajes de depuración en la consola para el cliente?",
        client_hud_display      = "¿Deberíamos mostrar elementos del HUD de Sublime Levels?",
        client_hud_blur         = "¿Deberíamos usar el desenfoque alrededor del menú?",
        client_hud_pos          = "Cambiar la posición del HUD",
        client_hud_bar          = "¿Deberíamos usar el hud de barra para la xp en lugar del circular?",
        client_xp_display       = "¿Deberíamos dar notificaciones de chat cuando obtenemos experiencia?",
        menu_open               = "¿Cuál debería ser la clave para abrir el menú de Sublime Levels? (def. F6)",
        blur                    = "¿Deberíamos usar el desenfoque alrededor del menú de Sublime Levels? (def. Sí)",
        hud_y                   = "¿Cuál debería ser la posición Y del HUD?",
        hud_x                   = "¿Cuál debería ser la posición X del HUD?",
        hud_bar                 = "¿Deberíamos usar la versión de barra del HUD? (def. No)",
        display                 = "¿Deberíamos usar el HUD de Sublime Levels en absoluto? (def. Sí)",
        debug_enabled           = "¿Deberíamos habilitar los mensajes de depuración para el cliente? (def. No)",

        experience_notifications    = "¿Deberían haber notificaciones de experiencia en el chat? (def. Sí)",
        hud_circle                  = "¿Deberíamos usar la versión Circle del HUD? (def. No)",
        hud_modern                  = "¿Deberíamos usar la versión Moderna del HUD? (def. Sí)",
    --

    -- Server Settings
        server_settings                     = "Ajustes del servidor",
        server_save                         = "Guardar ajustes del servidor",
        server_default                      = "Reiniciar ajustes del servidor",
        server_access_denied                = "ACCESO AL SERVIDOR DENEGADO",
        server_chat_command                 = "Cambiar el comando de chat para el menú. El prefijo ! y / ya está incluido.",
        server_kills_npc                    = "¿Cuánta XP debe recibir el jugador después de matar a un NPC?",
        server_kills_player                 = "¿Cuánta XP debe recibir el jugador después de matar a otro jugador?",
        server_kills_headshot               = "¿Cuánta XP extra debe recibir el jugador después de matar algo con un tiro en la cabeza?",
        server_other_vip                    = "¿Cuánta XP extra deben recibir los jugadores VIP? <Esto se aplica a todo>",
        server_other_max                    = "¿Cuál es el nivel máximo que puede alcanzar un jugador?",
        server_other_base_xp                = "¿Cuál debe ser la experiencia base para todos los jugadores? <Cuanto más alto sea, más difícil será subir de nivel>",
        server_other_base_xp_mod            = "¿Cuál debe ser el modificador de experiencia base para todos los jugadores? <Cuanto más alto sea, más difícil será subir de nivel>",
        server_other_debug                  = "¿Deberíamos habilitar los mensajes de depuración en la consola para el servidor?",
        server_other_xp_for_playing         = "¿Cuánta experiencia deberían obtener solo por jugar en el servidor?",
        server_other_xp_when                = "¿Con qué frecuencia deberían recibir experiencia solo por jugar? Estos están en segundos.",
        server_other_prefix                 = "¿Cuál debería ser el prefijo para las notificaciones de nivel / xp?",
        server_other_disable_notifications  = "¿Deshabilitar completamente las notificaciones de chat del cliente?",

        server_ttt                          = "Trouble in terrorist town",
        server_darkrp                       = "DarkRP",
        server_murder                       = "Murder",
        server_other                        = "Otros",
        server_kills                        = "Asesinatos",
        
        npc_on_kill_experience                  = "¿Cuánta experiencia deben recibir los jugadores al matar a un NPC? (Por defecto 100)",
        player_on_kill_experience               = "¿Cuánta experiencia deben recibir los jugadores al matar a otro jugador? (Por defecto 150)",
        headshot_modifier                       = "¿Cuál debe ser el modificador de tiro en la cabeza? Ejemplo: 100 * 1.2 = 120. (Por defecto 1.2)",
        vip_modifier                            = "¿Cuánta experiencia extra deben recibir los jugadores VIP? Example: 100 * 2 = 200. (Por defecto 2)",
        chat_command                            = "¿Cuál debe ser el comando de chat para abrir el menú?",
        max_level                               = "¿Cuál debe ser el nivel máximo? (Por defecto 99)",
        xp_for_playing_when                     = "¿Con qué frecuencia deben recibir los jugadores experiencia solo por jugar, en segundos? (Por defecto 600)",
        xp_for_playing                          = "¿Cuánta experiencia deben recibir los jugadores solo por jugar en el servidor? (Por defecto 25)",
        debug_enabled                           = "¿Deberíamos habilitar el modo de depuración en el lado del servidor? (Por defecto No)",
        sound_on_level                          = "¿Qué sonido deberíamos reproducir para el jugador cuando suba de nivel?",
        sound_on_xp                             = "¿Qué sonido deberíamos reproducir para los jugadores cuando reciban experiencia?",
        disable_notifications                   = "¿Deberíamos deshabilitar globalmente las notificaciones (notificaciones, sonidos, etc)? (Por defecto No)",
        chat_prefix                             = "Prefijo de chat al recibir notificaciones. (Por defecto [SublimeLevels])",
        lottery_winner                          = "¿Cuánta experiencia deben recibir los jugadores que ganan la lotería? (Por defecto 2000)",
        hitman_completed                        = "¿Cuánta experiencia deben recibir los sicarios por completar su objetivo? (Por defecto 300)",
        player_arrested                         = "¿Cuánta experiencia deben recibir los oficiales cuando arrestan a alguien? (Por defecto 75)",
        player_taxed                            = "¿Cuánta experiencia deben recibir los jugadores cuando son tributados? (Por defecto 25)",
        killing_traitors                        = "¿Cuánta experiencia deben recibir los jugadores cuando matan a un traidor? (Por defecto 200)",
        killing_innocent                        = "¿Cuánta experiencia deben recibir los jugadores cuando matan a un inocente? (Por defecto 50)",
        killing_detective                       = "¿Cuánta experiencia deben recibir los jugadores cuando matan a un detective? (Por defecto 200)",
        traitor_winners                         = "¿Cuánta experiencia deben recibir los traidores cuando ganan la ronda? (Por defecto 200)",
        innocent_winners                        = "¿Cuánta experiencia deben recibir los inocentes cuando ganan la ronda? (Por defecto 200)",
        draw                                    = "¿Cuánta experiencia deben recibir los jugadores cuando la ronda termina en empate? (Por defecto 50)",
        should_innocent_get_xp_when_dead        = "¿Deberían los inocentes recibir experiencia cuando están muertos? (Por defecto No)",
        should_traitor_get_xp_when_dead         = "¿Deberían los traidores recibir experiencia cuando están muertos? (Por defecto Sí)",
        should_spectators_get_xp_when_roundend  = "¿Deberían los espectadores recibir experiencia cuando termina la ronda? (Por defecto No)",
        murderer_winners                        = "¿Cuánta experiencia debe obtener el asesino cuando gana la ronda? (Por defecto 500)",
        bystander_winners                       = "¿Cuánta experiencia deben recibir los transeúntes cuando ganan la ronda? (Por defecto 250)",
        needed_on_server_before_xp              = "¿Cuántos jugadores son necesarios en el servidor antes de dar experiencia? (Por defecto 4)",
        should_broadcast_levelup                = "¿Deberíamos anunciar el nivel de los jugadores a otros jugadores? (Por defecto Sí)",
        tax_cooldown                            = "How often can players receive experience upon being taxed? (This is in seconds.) Def. 20",


        server_skills_strength_en   = "¿Deberia estar activo el árbol de fuerza?",

        server_darkrp_lottery       = "¿Cuánto XP debemos dar al ganador de la lotería?",
        server_darkrp_hitman        = "¿Cuánto XP debemos dar al asesino a sueldo por completar con éxito un golpe?",
        server_darkrp_arrested      = "¿Cuánto XP debemos dar a los oficiales de policía que arrestan a las personas?",
        server_darkrp_taxed         = "¿Cuánto XP deben recibir los jugadores al ser taxados?",

        server_ttt_traitor_win      = "¿Cuánto XP deben recibir los traidores al ganar una ronda?",
        server_ttt_innocent_win     = "¿Cuánto XP deben recibir los inocentes al ganar una ronda?",
        server_ttt_draw_win         = "¿Cuánto XP deben recibir todos si el juego termina en empate?",

    --

    -- Database settings.
        database_name = "Database",
        database_reset = "Reset user data",
        database_reset_description = "This will reset all user data, and will not be able to be undone. Are you sure you want to do this?",
        database_delete = "Delete user data",
        database_delete_description = "This will delete the user data of the selected user. Are you sure you want to do this?",
        database_profile_tip = "Opens the profile of the selected user in the steam overlay.",
        database_copy_steamid_tip = "Copies the steamid of the selected user to your clipboard.",
        database_set_level_tip = "Sets the level of the selected user to the specified level.\nthis can not be more than what the max level has been set in the config.",
        database_give_xp_tip = "Gives the selected user the specified amount of experience. This should not be more than what the player needs to level up.",
        database_give_skill_tip = "Gives the selected user the specified amount of skill points.",
        database_take_skill_tip = "Takes the specified amount of skill points from the selected user. If you take more than what the user has, they will end up in the negative.",
        database_reset_user_tip = "Completely resets the players data, this will remove all of their levels, experience, skill points and skills.\nIf the player is on the server then they will be kicked.",
    --
    

    -- Skill settings.
        skill_settings = "Configuraciones de habilidades",
    --
}