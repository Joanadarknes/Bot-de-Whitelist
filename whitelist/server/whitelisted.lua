-- Configurações
Config = {
    Token = 'MTI3MTA5NTA4MzYyOTkzNjY0Mg.GN0XuJ.a9PvuXaQjwtKC-xUtFiWxzIftkNKvtfhvjqVoM',  -- Token do bot
    ChannelID = '1270908445419110561',  -- ID do canal onde a mensagem será enviada
    ServerName = 'Sacomã City',  -- NOME DO SERVIDOR
    EmbedColor = 2303786,
    WebhookIcon = 'https://cdn.discordapp.com/attachments/1247383661167509602/1272634376101822464/frame.png?ex=66c2481f&is=66c0f69f&hm=97bb609e52d9a81a80e656526998b109709c985c53ad5655b6fb23cf005274ba&'  -- imagem da logo
}

-- Função para obter a data e hora atual
function getCurrentDateTime()
    local date = os.date("*t")
    return string.format("%02d/%02d/%04d %02d:%02d", date.day, date.month, date.year, date.hour, date.min)
end

-- Função para enviar mensagem com embed e botão usando o bot
function sendBotMessage()
    local currentDateTime = getCurrentDateTime()

    local embed = {
        {
            title = "Processo de Whitelist Sacomã City",
            description = "Clique no botão abaixo para iniciar o processo de whitelist.",
            color = Config.EmbedColor,
            thumbnail = {
                url = Config.WebhookIcon
            },
            footer = {
                text = "Atenciosamente Sacomã City • " .. currentDateTime
            }
        }
    }

    local component = {
        type = 1,
        components = {
            {
                type = 2,
                style = 3, -- Success (verde)
                label = "✅ Iniciar whitelist",
                custom_id = "start_whitelist"
            }
        }
    }

    local data = {
        content = nil,
        embeds = embed,
        components = {component}
    }

    PerformHttpRequest('https://discord.com/api/v10/channels/' .. Config.ChannelID .. '/messages', function(err, text, headers) 
        if err ~= 200 then
            print('Erro ao enviar mensagem para o canal: ' .. err .. ' - ' .. text)
        else
            print('Mensagem enviada com sucesso: ' .. text)
        end
    end, 'POST', json.encode(data), {
        ['Content-Type'] = 'application/json',
        ['Authorization'] = 'Bot ' .. Config.Token
    })
end

-- Função para verificar se o embed já existe e enviar o novo
function checkAndSendEmbed()
    PerformHttpRequest('https://discord.com/api/v10/channels/' .. Config.ChannelID .. '/messages', function(err, text, headers)
        if err ~= 200 then
            print('Erro ao buscar mensagens: ' .. err .. ' - ' .. text)
            return
        end
        local messages = json.decode(text)
        local embedFound = false
        local messageIdToDelete
        for _, message in ipairs(messages) do
            if message.embeds and #message.embeds > 0 then
                local embed = message.embeds[1]
                if embed.title == "Processo de Whitelist Sacomã City" then
                    embedFound = true
                    messageIdToDelete = message.id
                    break
                end
            end
        end
        if embedFound then
            -- Apaga a mensagem antiga
            PerformHttpRequest('https://discord.com/api/v10/channels/' .. Config.ChannelID .. '/messages/' .. messageIdToDelete, function(err, text, headers)
                if err ~= 204 then
                    print('Erro ao apagar mensagem: ' .. err .. ' - ' .. text)
                end
            end, 'DELETE', nil, {
                ['Authorization'] = 'Bot ' .. Config.Token
            })
        end
        -- Envia a nova mensagem apenas se não houver duplicação
        sendBotMessage()
    end, 'GET', nil, {
        ['Authorization'] = 'Bot ' .. Config.Token
    })
end


-- Chame essa função onde você deseja enviar a mensagem
checkAndSendEmbed()

-- Trata mensagens recebidas no canal específico
AddEventHandler('onMessageCreate', function(message)
    print('Mensagem recebida: ' .. message.content) -- Depuração
    if message.channel_id == '1271140776721645589' then
        local content = message.content:gsub('%s+', '')

        if content == '' then
            return
        end

        if not content:match('^%d+$') then
            sendBotMessage('O ID informado deve ser numérico.')
            return
        end

        local userId = content

        if cooldown[userId] then
            sendBotMessage('Você já enviou uma solicitação recentemente.')
            return
        end

        cooldown[userId] = os.time()
        Citizen.SetTimeout(30000, function() cooldown[userId] = nil end) -- Cooldown de 30 segundos

        local query = 'UPDATE vrp_users SET whitelisted = 1 WHERE id = @id'
        MySQL.Async.execute(query, {['@id'] = userId}, function(affectedRows)
            if affectedRows > 0 then
                sendBotMessage('Usuário com ID ' .. userId .. ' foi adicionado à whitelist com sucesso!')
            else
                sendBotMessage('Nenhum usuário encontrado com o ID ' .. userId .. '.')
            end
        end)
    end
end)
