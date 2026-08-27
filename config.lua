Config = {}

Config.Enabled = true
Config.Debug = false
Config.TimeBeforeAfkCheck = 10 * 60 -- ile sekund bez ruchu zanim wyskoczy ci stary na głowe
Config.TimeToAnswer = 30 -- ile sekund na wpisanie kodu zanim leci kick
Config.CheckInterval = 1000 -- co ile ms sprawdzamy pozycję/kamerę
Config.MovementThreshold = 0.15
Config.CameraThreshold = 0.5
Config.IgnoreWhenDead = true
Config.ActivityControls = { -- klawisze liczone jako aktywność gracza
    30, 31, 32, 33, 34, 35, -- ruch
    1, 2,                   -- kamera/mysz
    21, 22, 23, 24, 25, 44, -- sprint, skok, interakcja, atak, cel, kucanie
    71, 72, 63, 64, 75,     -- pojazd
}
Config.PhraseLength = 6
Config.PhraseCharset = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
Config.DisableControlsDuringCheck = true
Config.FreezePlayerDuringCheck = true
Config.PlaySound = true
Config.SoundName = "Lose_1st_Place"
Config.SoundSet = "GTAO_FM_Events_Soundset"
Config.KickMessage = "Zostałeś wyrzucony z serwera za brak aktywności (AFK)."
Config.AdminAcePermission = "antiafk.admin" -- uprawnienie do komendy /forceafk (testowanie)

Config.Webhook = {
    enabled = false,
    url = "",
    name = "AntiAFK",
    color = 15158332,
}

Config.Locale = {
    title = "WERYFIKACJA AKTYWNOŚCI",
    subtitle = "Wykryto brak aktywności. Przepisz poniższy kod, aby pozostać na serwerze.",
    inputPlaceholder = "wpisz kod",
    timeLeftLabel = "Pozostały czas",
    wrongCode = "Błędny kod! Spróbuj ponownie.",
    kickWarning = "Zostaniesz wyrzucony z serwera po upływie czasu!",
}
