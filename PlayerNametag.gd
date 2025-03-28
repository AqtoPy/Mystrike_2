func update_nametag():
    var color: Color = Color.WHITE
    
    if PlayerData.is_vip:
        color = Color.GOLD
    elif PlayerData.is_developer:
        color = Color.DEEP_SKY_BLUE
    
    $Nametag.set("theme_override_colors/font_color", color)
    $Nametag.text = PlayerData.player_name
