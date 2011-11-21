global.chatBoxOpen = 0;
global.chatBoxHidden = 0;
global.chatters = ds_list_create();
global.redChatBuffer = buffer_create();
global.blueChatBuffer = buffer_create();
global.publicChatBuffer = buffer_create();
global.chatLog = ds_list_create();
global.chatFadeTimers = ds_list_create();
