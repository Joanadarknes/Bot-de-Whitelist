-- Configurações
Config = {
    Debug = true,
    Webhook = 'https://discord.com/api/webhooks/1274451323324203008/rixJqXNLScRXs6hqsSyLq50U2LjaydBbTi4Opvv3U8Md0B0101yZw03oY3fcdd8l25lA',
    ServerName = 'Sacomã City',
    ChannelId = '1270908445419110561',
    GuildId = '1094239383672070194',
    RoleId = '1270931160305766461',
    EmbedColor = 2303786,
    WebhookIcon = 'https://cdn.discordapp.com/attachments/1247383661167509602/1272634376101822464/frame.png'
}

-- Requer o mysql-async
local MySQL = exports['mysql-async']:getMySQL()

-- Função para enviar mensagem via webhook
function sendWebhookMessage(content, embed)
    local webhookData = {
        content = content,
        username = Config.ServerName,
        avatar_url = Config.WebhookIcon,
        embeds = embed and { embed } or nil
    }

    local webhookDataJson = json.encode(webhookData)
    PerformHttpRequest(Config.Webhook, function(err, text, headers) 
        if err ~= 200 then
            print('Erro ao enviar mensagem para o webhook: ' .. err .. ' - ' .. text)
        else
            print('Mensagem enviada com sucesso: ' .. text)
        end
    end, 'POST', webhookDataJson, {['Content-Type'] = 'application/json'})
end

-- Exemplo de como usar a função para enviar um embed
local function handleUserWhitelist(userId, success)
    local embed = {
        title = success and "Whitelist Sucesso" or "Whitelist Falhou",
        description = success and ('Usuário com ID ' .. userId .. ' foi adicionado à whitelist com sucesso!') or ('Nenhum usuário encontrado com o ID ' .. userId .. '.'),
        color = Config.EmbedColor
    }

    sendWebhookMessage(nil, embed)
end

-- Função para criar um canal e enviar o quiz
function createWhitelistChannel(userId, username)
    print('Criando canal para o usuário: ' .. username)

    local newChannelName = 'whitelist-' .. username

    -- Simulação de criação de canal (substitua com a API real do FiveM)
    -- (A criação de canais deve ser feita usando a API do FiveM)

    local correctAnswers = 0

    -- Perguntas e respostas do quiz
    local questions = {
        { question = 'Qual é a capital da França?', options = {'Paris', 'Londres', 'Roma'}, answer = 'Paris' },
        { question = 'Qual é o maior planeta do sistema solar?', options = {'Terra', 'Júpiter', 'Marte'}, answer = 'Júpiter' },
        { question = 'Qual é o elemento químico com símbolo H?', options = {'Hidrogênio', 'Hélio', 'Oxigênio'}, answer = 'Hidrogênio' },
        { question = 'Quem escreveu "Dom Casmurro"?', options = {'Machado de Assis', 'José de Alencar', 'Jorge Amado'}, answer = 'Machado de Assis' },
        { question = 'Qual é o maior oceano da Terra?', options = {'Atlântico', 'Índico', 'Pacífico'}, answer = 'Pacífico' }
    }

    for _, question in ipairs(questions) do
        -- Simular a resposta correta
        correctAnswers = correctAnswers + 1 -- Simulação: considere sempre correto
    end

    -- Verifica se o usuário passou no quiz
    if correctAnswers >= 4 then
        print('Quiz concluído com sucesso para o usuário: ' .. username)
        sendWebhookMessage('Parabéns! Você acertou ' .. correctAnswers .. ' perguntas de 5. Por favor, informe o ID do seu personagem FiveM.')
    else
        print('Usuário não passou no quiz: ' .. username)
        sendWebhookMessage('Você não passou no quiz para a whitelist.')
    end
end


-- Inicia o processo de whitelist quando um botão é pressionado
AddEventHandler('onButtonPress', function(buttonId, userId)
    if buttonId == 'start_whitelist' then
        -- Verifica se o usuário tem o papel necessário e cria o canal
        -- (Substitua com a lógica para verificar papéis e criar canais)
        createWhitelistChannel(userId, 'UserName') -- Substitua 'UserName' pelo nome real do usuário
    end
end)
