local get_next_player_enum = function(game_state)
    if game_state.turn == Enums.Actors.PLAYER then
        return Enums.Actors.ENEMY
    elseif game_state.turn == Enums.Actors.ENEMY then
        return Enums.Actors.PLAYER
    end
end

local are_player_buttons_enabled = function(game_state)
    return not game_state.buttons.shoot.disabled and not game_state.buttons.pass.disabled
end

local set_in_dialog = function(game_state)
    game_state.in_dialog = true
    game_state.buttons.shoot.disabled = true
    game_state.buttons.pass.disabled = true
end

return {
    get_next_player_enum = get_next_player_enum,
    are_player_buttons_enabled = are_player_buttons_enabled,
    set_in_dialog = set_in_dialog,
}