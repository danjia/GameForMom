


visibleSize   = CCDirector:sharedDirector():getVisibleSize()
WIDTH    = visibleSize.width
HEIGHT   = visibleSize.height
CENTER_X = WIDTH/2
CENTER_Y = HEIGHT/2

--音效
SOUND_BUTTON_CLICK  = "music/Button.ogg"
SOUND_ICON_CLICK    = "music/Button.ogg"
SOUND_ICON_CONNECT1 = "music/IconConnect1.ogg"
SOUND_ICON_CONNECT2 = "music/IconConnect2.ogg"
SOUND_SUCCESS       = "music/Success.ogg"
SOUND_FAILE         = "music/Faile.ogg"

--音乐
MUSIC_BACKGROUND1   = "music/Music1.ogg"
MUSIC_BACKGROUND2   = "music/Music1.ogg"



--状态
STATE_NONE         = 0 --无
STATE_GAME_PLAYING = 1 --游戏进行中
STATE_TIME_OVER    = 2 --时间到
STATE_PAUSE        = 3 --暂停
STATE_RESUME       = 4 --重新开始
STATE_WIN          = 5 --胜利
STATE_FAILE        = 6 --失败

