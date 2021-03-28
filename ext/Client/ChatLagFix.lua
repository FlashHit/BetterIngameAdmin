class 'ChatLagFix'

function ChatLagFix:__init()
    ResourceManager:RegisterInstanceLoadHandler(Guid('3E6AF1E2-B10E-11DF-9395-96FA88A245BF'), Guid('78B3E33E-098B-3320-ED15-89A36F04007B'), function(instance)
        instance = UIMessageCompData(instance)
        instance:MakeWritable()
        MessageInfo(instance.chatMessageInfo).messageQueueSize = 20
    end)
end

return ChatLagFix