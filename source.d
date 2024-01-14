// Isto e um jogo onde voce escolhe solucoes para os problemas do mundo.

// isto é para não mostrar a tela do prompt na hora que abrir o jogo
pragma(linkerDirective, "/subsystem:windows");
pragma(linkerDirective, "/entry:mainCRTStartup");

import arsd.image : loadImageFromFile;
import arsd.simpleaudio : AudioOutputThread;
import arsd.simpledisplay : Color, Image, Key, KeyEvent, OperatingSystemFont, Pen, Point, ScreenPainter, SimpleWindow;
import std.stdio;
import std.string : wrap;

// esta estrutura vai modelar os cenários do jogo
struct Cenario
{
    // isso vai ser o nome
    string nome;
    // isso vai ser a imagem do cenario
    Image img;
    // esses vão ser a frase dele em Portugues e Ingles
    string frasePortugues, fraseIngles;
    // esses vão ser os arrays com as opcoes dele, em Portugues e Ingles
    string[3] opçoesPortugues, opçoesIngles;

    // esse é o construtor da struct
    this (string nome, Image img, string frasePortugues, string fraseIngles, string[3] opçoesPortugues, string[3] opçoesIngles)
    {
        this.nome = nome;
        this.img = img;
        this.frasePortugues = frasePortugues, this.fraseIngles = fraseIngles;
        this.opçoesPortugues = opçoesPortugues, this.opçoesIngles = opçoesIngles;
    }
}

void main()
{
    // criamos a janela do jogo
    SimpleWindow janela = new SimpleWindow(800, 800, "Videogame");
    // carregamos as imagens que vamos usar no jogo
    Image introImg = Image.fromMemoryImage(loadImageFromFile("imagens/intro.jpeg")),
          finalImg = Image.fromMemoryImage(loadImageFromFile("imagens/final.jpeg"));
    // criamos as fontes que serao usadas ao longo do jogo
    OperatingSystemFont fonteGrande = new OperatingSystemFont("Calibri", 50), fonteMedia = new OperatingSystemFont("Calibri", 25),
                        fontePequena = new OperatingSystemFont("Calibri", 18);
    // esses booleans vão ajudar o loop de eventos a saber o que fazer, 'escolhendoLingua' comeca igual a true pois vai ser o comeco do jogo
    bool escolhendoLingua = true, menuInicial, lendoInstruçoes, jogando, telaFinal;
    // 'opcao' vai dizer qual opcao o usuario esta selecionando, 'cenarioAtual' vai dizer qual o cenario atual
    int opçao, cenarioAtual;
    // esse array vai conter as opcoes que o usuario pode escolher em cada cenario
    string[3] opçoesAtuais;
    // esse array vai armazenar todas as respostas que o usuario escolhe ao longo do jogo
    int[6] respostas;
    // 'lingua' vai dizer em qual lingua o jogo vai ser jogado, em Portugues ou Ingles, 'fraseAtual' vai dizer qual a frase a ser mostrada
    string lingua, fraseAtual;

    // criamos todos os cenários do jogo
    Cenario primeiro = Cenario("energia", Image.fromMemoryImage(loadImageFromFile("imagens/1.jpeg")),
                               "O mundo precisa de energia para manter toda a indústria e todas as cidades funcionando. Qual seria a melhor forma de energia na qual investir?",
                               "The world needs energy to keep all the industry and all the cities working. What would be the best form of energy to invest in?",
                               [wrap("Painéis solares", 20), wrap("Combustão", 20), wrap("Usinas nucleares", 20)],
                               [wrap("Solar panels", 20), wrap("Combustion", 20), wrap("Nuclear powerplants", 20)]),
            segundo = Cenario("educaçao", Image.fromMemoryImage(loadImageFromFile("imagens/2.jpeg")),
                               "Até hoje existem milhões de pessoas analfabetas, qual seria a melhor estratégia para ensinar todo mundo a ler?",
                               "To this day there are millions of illiterate people, what would be the best strategy to teach everybody how to read?",
                               [wrap("Mais professores", 20), wrap("Apps que ensinam com IA", 20), wrap("Mais escolas", 20)],
                               [wrap("More teachers", 20), wrap("Apps that teach with AI", 20), wrap("More schools", 20)]),
            terceiro = Cenario("fome", Image.fromMemoryImage(loadImageFromFile("imagens/3.jpeg")),
                               "Milhões de pessoas passam fome todos os anos ao redor do mundo, principalmente nos países de terceiro mundo. Qual seria uma boa ideia para melhorar isso?",
                               "Millions of people starve every year across the world, mainly in the third world countries. What would be a good idea to make this better?",
                               [wrap("Produzir mais comida", 20), wrap("Investir em agronomia", 20), wrap("Melhorar a distribuição de comida", 20)],
                               [wrap("Produce more food", 20), wrap("Invest in agriculture", 20), wrap("Improve food distribution", 20)]),
            quarto = Cenario("mulheres", Image.fromMemoryImage(loadImageFromFile("imagens/4.jpeg")),
                             "Hoje em dia ainda existem muitos países onde mulheres são tratadas como inferiores. Qual seria uma boa forma de ajudá-las?",
                             "Nowadays there are still many countries where women are treated as inferior people. What would be a good way to help them?",
                             [wrap("Educação e empoderamento feminino", 20), wrap("Propaganda feminista na TV", 20), wrap("Centros de apoio a mulheres", 20)],
                             [wrap("Female education and empowerment", 20), wrap("Feminist ads on TV", 20), wrap("Support centers for women", 20)]),
            quinto = Cenario("oceano", Image.fromMemoryImage(loadImageFromFile("imagens/5.jpeg")),
                             "Toneladas de lixo plástico são jogadas nos oceanos todos os anos, especialmente em países pobres. O que fazer para acabar com isso?",
                             "Tons of plastic garbage are tossed in the ocean every year, specially in poor countries. What should we do to end that?",
                             [wrap("Proibir o uso de plástico", 20), wrap("Mais centros de reciclagem", 20), wrap("Enviar barcos para limpar os oceanos", 20)],
                             [wrap("Forbid the use of plastic", 20), wrap("More recycling centers", 20), wrap("Send boats to clean the oceans", 20)]),
            sexto = Cenario("amazonia", Image.fromMemoryImage(loadImageFromFile("imagens/6.jpeg")),
                            "Todos os anos um pedaço da Amazônia é destruído por desmatamento e por incêndios, como podemos salvar a maior floresta tropical do planeta?",
                            "Every year a piece of Amazon is destroyed by people cutting it down and by fires, how can we save the biggest rainforest on the planet?",
                            [wrap("Aumentar o policiamento", 20), wrap("Replantar as áreas destruídas", 20), wrap("Investir nas ONGs de preservação", 20)],
                            [wrap("Increase the forest's policing", 20), wrap("Replant the destroyed areas", 20), wrap("Invest in preservation NGOs", 20)]);

    // este array vai conter todos os cenarios do jogo
    Cenario[6] listaCenarios = [primeiro, segundo, terceiro, quarto, quinto, sexto];

    // criamos as avaliações que você receberá no final do jogo para saber quais resultados atingiu
    string[3][6] avaliaçoesPt = [["Painéis solares: painéis solares ainda possuem uma baixa eficiência e geram poluição para serem produzidos e descartados.",
                                  "Combustão: combustão gera quantidades absurdas de gás carbônico e isso prejudica o ambiente e a saúde das pessoas.",
                                  "Usinas nucleares: a energia nuclear além de limpa também é muito eficiente, a nossa melhor alternativa até agora."],
                                 ["Mais professores: ter mais professores ajuda porém não é suficiente em um mundo tão complexo como o nosso.",
                                  "Apps que ensinam com IA: hoje em dia todo mundo tem um smartphone e portanto pode usar um app para aprender a ler, uma IA hoje em dia consegue conversar direito com uma pessoa.",
                                  "Mais escolas: construir mais escolas no mundo inteiro ainda é uma alternativa muito cara."],
                                 ["Produzir mais comida: já produzimos mais comida do que o mundo precisa, o problema é a distribuição de alimentos.",
                                  "Investir em agronomia: hoje em dia já temos muita tecnologia para agronomia, o que precisamos é fazer os alimentos chegarem na mesa da casa das pessoas.",
                                  "Melhorar a distribuição de comida: com melhor distribuição de alimentos será possível erradicar a fome, hoje em dia podemos usar nossa tecnologia para fazer essa distribuição."],
                                 ["Educação e empoderamento feminino: a melhor ferramenta para um oprimido é ser independente do opressor, essa é a melhor solução.",
                                  "Propaganda feminista na TV: isso já vem sendo feito a muito tempo e não ajuda muito.",
                                  "Centros de apoio a mulheres: isso iria apenas amenizar o problema."],
                                 ["Proibir o uso de plástico: proibir plástico seria totalmente fora de realidade.",
                                  "Mais centros de reciclagem: o plástico pode facilmente ser reciclado para fazer muitos produtos diferentes, a reciclagem seria a melhor ideia.",
                                  "Enviar barcos para limpar os oceanos: isso seria inviável devido a grande quantidade de plástico nos oceanos e a vastidão dos oceanos."],
                                 ["Aumentar o policiamento: a floresta amazônica é grande demais para ser totalmente policiada.",
                                  "Replantar as áreas destruídas: é possível recuperar o que foi perdido, com o uso de tecnologias para o reflorestamento em larga escala.",
                                  "Investir nas ONGs de preservação: já existem muitas ONGs protegendo a Amazônia, mas infelizmente elas não conseguem proteger uma floresta tão grande."]],
                 avaliaçoesEn = [["Solar panels: solar panels still have a low eficiency and they produce polution when they are produced and discarded.",
                                  "Combustion: combustion produces absurd amounts of carbon gas and that harms the environment and people's health.",
                                  "Nuclear powerplants: nuclear energy is clean and also very efficient, our best alternative so far."],
                                 ["More teachers: having more teachers would help but it isn't enough in a world as complex as ours.",
                                  "Apps that teach with AI: nowadays everyone has a smartphone, therefore they can use an app to learn how to read, an IA today can properly talk to a person.",
                                  "More schools: building more schools around the whole world is still a very expensive alternative."],
                                 ["Produce more food: we already produce more food than the world needs, the problem is in the distribuition of food.",
                                  "Invest in agriculture: nowadays we already have so much technology for agriculture, what we need is to make the food arrive on people's table.",
                                  "Improve food distribution: with better distribution of food it will be possible to erradicate hunger, nowadays we can use our technology to make this distribution."],
                                 ["Female education and empowerment: the best tool for an opressed is to be independent of the opressor, this is the best solution.",
                                  "Feminist ads on TV: they have already been doing that for long time and it doesn't help much.",
                                  "Support centers for women: this would only make the problem a bit better."],
                                 ["Forbid the use of plastic: to forbid plastic would be totally unrealistic.",
                                  "More recycling centers: plastic can be easily recycled to make many different products, recycling would be the best idea.",
                                  "Send boats to clean the oceans: that would be impossible due to the large amount of plastic in the oceans and the vastness of the oceans."],
                                 ["Increase the forest's policing: the Amazon jungle is too big to be totally policed.",
                                  "Replant the destroyed areas: it is possible to recover what has been lost, with the use of technologies for large scale reforestation.",
                                  "Invest in preservation NGOs: there are already many NGOs protecting the Amazon, but unfortunately they are unable to protect such a big forest."]];

    // criamos a thread que vai tocar o audio do jogo
    AudioOutputThread audio = AudioOutputThread(true);
    // comeca a tocar a trilha sonora
    audio.playOgg("trilha sonora.ogg", true);

    // começamos o loop de eventos da janela do jogo
    janela.eventLoop(100,
    {
        // criamos o pintor que irá desenhar tudo na tela do computador
        ScreenPainter pintor = janela.draw();

        // se você estiver na tela de escolher a língua do jogo
        if (escolhendoLingua)
        {
            // pega a fonte grande
            pintor.setFont(fonteGrande);
            // desenha a tela de introducao
            pintor.drawImage(Point(0, 0), introImg);
            // pega a cor branca
            pintor.outlineColor = Color.white();
            // escreve "Portugues" na tela
            pintor.drawText(Point(85, 725), "Português");
            // escreve "Ingles" em outra parte da tela
            pintor.drawText(Point(560, 725), "English");
            // muda a caneta para ficar mais grossa e verde
            pintor.pen = Pen(Color.green(), 5);

            // se voce selecionar a primeira opcao
            if (opçao == 0)
                // coloca uma linha em cima para destacar
                pintor.drawLine(Point(85, 720), Point(270, 720));
            // se voce selecionar a segunda opcao
            else if (opçao == 1)
                // coloca uma linha em cima para destacar
                pintor.drawLine(Point(560, 720), Point(690, 720));
        }
        // se você estiver na tela do menu inicial do jogo
        else if (menuInicial)
        {
            // pega a fonte grande
            pintor.setFont(fonteGrande);
            // desenha a imagem da introducao
            pintor.drawImage(Point(0, 0), introImg);
            // pega a cor preta para o contorno e o interior
            pintor.outlineColor = Color.black(), pintor.fillColor = Color.black();
            // desenha um retangulo preto
            pintor.drawRectangle(Point(140, 290), 515, 65);
            // pega a cor vermelha
            pintor.outlineColor = Color.red();
            // escreve o titulo do jogo, de acordo com a lingua escolhida
            pintor.drawText(Point(lingua == "Portugues" ? 175 : 245, 300), lingua == "Portugues" ? "CONSERTANDO O MUNDO" : "FIXING THE WORLD");
            // pega a cor branca
            pintor.outlineColor = Color.white();
            // escreve a opcao de voltar, de acordo com a lingua
            pintor.drawText(Point(70, 725), lingua == "Portugues" ? "Voltar" : "Back");
            // escreve a opcao de iniciar, de acordo com a lingua
            pintor.drawText(Point(330, 725), lingua == "Portugues" ? "Iniciar" : "Start");
            // escreve a opcao de instrucoes, de acordo com a lingua
            pintor.drawText(Point(560, 725), lingua == "Portugues" ? "Instruções" : "Instructions");
            // deixa a caneta mais grossa e verde
            pintor.pen = Pen(Color.green(), 5);

            // se a primeira opcao estiver selecionada
            if (opçao == 0)
                // desenha uma linha em cima para destacar
                pintor.drawLine(Point(70, 720), Point(180, 720));
            // se a segunda opcao estiver selecionada
            else if (opçao == 1)
                // desenha uma linha em cima para destacar
                pintor.drawLine(Point(330, 720), Point(445, 720));
            // se a terceira opcao estiver selecionada
            else if (opçao == 2)
                // desenha uma linha em cima para destacar
                pintor.drawLine(Point(560, 720), Point(775, 720));
        }
        // se você estiver na tela de ler as intruções do jogo
        else if (lendoInstruçoes)
        {
            // desenha a imagem de introducao
            pintor.drawImage(Point(0, 0), introImg);
            // pega a cor preta para o contorno e o interior
            pintor.outlineColor = Color.black(), pintor.fillColor = Color.black();
            // desenha um retangulo preto
            pintor.drawRectangle(Point(280, 280), 240, 160);
            // pega a cor branca
            pintor.outlineColor = Color.white();
            // pega a fonte pequena
            pintor.setFont(fontePequena);
            // escreve as instrucoes na tela, de acordo com a lingua escolhida
            pintor.drawText(Point(300, 300), lingua == "Portugues" ? "Este jogo irá te permitir consertar\nos problemas do mundo através\nde decisões.\nVocê deve escolher a opção\ndesejada para passar para a\npróxima etapa." : "This game will allow you to fix\nthe problems of the world\nthrough decisions.\nYou must choose the desired\noption in order to move on to\nthe next stage.", Point(505, 500));
            // pega a fonte grande
            pintor.setFont(fonteGrande);
            // escreve a opcao de voltar, de acordo com a lingua
            pintor.drawText(Point(70, 725), lingua == "Portugues" ? "Voltar" : "Back");
            // deixa a caneta mais grossa e verde
            pintor.pen = Pen(Color.green(), 5);
            // desenha uma linha em cima da opcao de voltar, para destacar
            pintor.drawLine(Point(70, 720), Point(180, 720));
        }
        // se você estiver nas telas de jogar o jogo
        else if (jogando)
        {
            // desenha a imagem do cenario
            pintor.drawImage(Point(0, 0), listaCenarios[cenarioAtual].img);
            // pega a cor preta para o contorno e o interior
            pintor.outlineColor = Color.black(), pintor.fillColor = Color.black();
            // desenha um retangulo preto
            pintor.drawRectangle(Point(280, 280), 240, 160);
            // deixa a caneta mais grossa e branca
            pintor.pen = Pen(Color.white(), 5);
            // pega a fonte pequena
            pintor.setFont(fontePequena);
            // pega a frase atual de acordo com a lingua escolhida
            fraseAtual = lingua == "Portugues" ? listaCenarios[cenarioAtual].frasePortugues : listaCenarios[cenarioAtual].fraseIngles;
            // pega as opcoes atuais de acordo com a lingua escolhida
            opçoesAtuais = lingua == "Portugues" ? listaCenarios[cenarioAtual].opçoesPortugues : listaCenarios[cenarioAtual].opçoesIngles;
            // escreve a frase atual, apos ajusta-la para nao ter mais de 30 caracteres por linha
            pintor.drawText(Point(300, 300), wrap(fraseAtual, 30), Point(505, 500));
            // pega a fonte media
            pintor.setFont(fonteMedia);
            // pega a cor branca
            pintor.outlineColor = Color.white();
            // escreve a opcao de voltar, de acordo com a lingua
            pintor.drawText(Point(30, 725), lingua == "Portugues" ? "Voltar" : "Back");
            // escreve a primeira opcao
            pintor.drawText(Point(160, 725), opçoesAtuais[0], Point(370, 800));
            // escreve a segunda opcao
            pintor.drawText(Point(370, 725), opçoesAtuais[1], Point(580, 800));
            // escreve a terceira opcao
            pintor.drawText(Point(580, 725), opçoesAtuais[2], Point(800, 800));
            // deixa a caneta mais grossa e verde
            pintor.pen = Pen(Color.green(), 5);

            // se tiver selecionado a primeira opcao
            if (opçao == 0)
                // desenha uma linha em cima para destacar
                pintor.drawLine(Point(20, 720), Point(100, 720));
            // se tiver selecionado a segunda opcao
            else if (opçao == 1)
                // desenha uma linha em cima para destacar
                pintor.drawLine(Point(160, 720), Point(310, 720));
            // se tiver selecionado a terceira opcao
            else if (opçao == 2)
                // desenha uma linha em cima para destacar
                pintor.drawLine(Point(370, 720), Point(520, 720));
            // se tiver selecionado a quarta opcao
            else if (opçao == 3)
                // desenha uma linha em cima para destacar
                pintor.drawLine(Point(580, 720), Point(730, 720));
        }
        // se você estiver na tela final do jogo
        else if (telaFinal)
        {
            // desenha a imagem final
            pintor.drawImage(Point(0, 0), finalImg);
            // pega a cor branca
            pintor.outlineColor = Color.white();
            // pega a fonte grande
            pintor.setFont(fonteGrande);
            // escreve a frase "RESULTADOS FINAIS" de acordo com a lingua escolhida
            pintor.drawText(Point(220, 100), lingua == "Portugues" ? "RESULTADOS FINAIS" : "FINAL RESULTS");
            // pega a fonte media
            pintor.setFont(fonteMedia);

            // coloca o 'y' igual a 80 para desenhar as frases na tela no local certo
            int y = 80;

            // usa um loop para desenhar todas as avaliacoes com os resultados do jogo
            foreach (i, frases; lingua == "Portugues" ? avaliaçoesPt : avaliaçoesEn)
                // desenha a frase com a resposta, depois de ajustar ela para nao ter mais de 70 caracteres por linha
                pintor.drawText(Point(150, y += 90), wrap(frases[respostas[i] - 1], 70), Point(800, y + 100));

            // pega a fonte grande
            pintor.setFont(fonteGrande);
            // escreve a opcao de jogar de novo, de acordo com a lingua escolhida
            pintor.drawText(Point(70, 725), lingua == "Portugues" ? "Jogar de novo" : "Play again");
            // deixa a caneta mais grossa e verde
            pintor.pen = Pen(Color.green(), 5);
            // desenha uma linha em cima da opcao de jogar de novo, para destacar
            pintor.drawLine(Point(70, 720), Point(320, 720));
        }
    },
    // registra eventos de botoes apertados
    (KeyEvent evento)
    {
        // se voce tiver apertado alguma coisa
        if (evento.pressed)
            // se voce apertar a seta pra direita
            if (evento.key == Key.Right)
            {
                // toca o som de um botao sendo apertado
                audio.playOgg("botao.ogg");

                // se voce estiver escolhendo alguma opcao em alguma das telas e nao estiver na ultima opcao
                if (escolhendoLingua && opçao < 1 || menuInicial && opçao < 2  || jogando && opçao < 3)
                    // incrementa o indice da opcao, para passar para a proxima
                    opçao++;
            }
            // se você apertar a seta pra esquerda
            else if (evento.key == Key.Left)
            {
                // toca o som de um botao sendo apertado
                audio.playOgg("botao.ogg");

                // se voce nao estiver na primeira opcao
                if (opçao > 0)
                    // decrementa o indice da opcao, para passar para a anterior
                    opçao--;
            }
            // se voce apertar Enter
            else if (evento.key == Key.Enter)
            {
                // toca o som do botao sendo apertado
                audio.playOgg("botao.ogg");

                // se estiver na tela de escolher a lingua
                if (escolhendoLingua)
                {
                    // se tiver selecionado a primeira opcao
                    if (opçao == 0)
                        // a lingua vai ser Portugues
                        lingua = "Portugues";
                    // se tiver selecionado a segunda opcao
                    else
                    {
                        // a lingua vai ser Ingles
                        lingua = "Ingles";
                        // coloca o indice de volta para 0, assim na proxima tela vai estar na primeira opcao
                        opçao = 0;
                    }

                    // atualiza esses booleans para dizer que ja passou para a tela do menu inicial
                    escolhendoLingua = false, menuInicial = true;
                }
                // se estiver na tela do menu inicial
                else if (menuInicial)
                {
                    // se tiver selecionado a primeira opcao
                    if (opçao == 0)
                        // atualiza esses boleans para voltar para a tela de escolher a lingua
                        menuInicial = false, escolhendoLingua = true;
                    // se tiver selecionado a segunda opcao
                    else if (opçao == 1)
                    {
                        // coloca o cenario atual como o primeiro, para comecar o jogo
                        cenarioAtual = 0;
                        // atualiza esses booleans para passar para a tela de jogar
                        menuInicial = false, jogando = true;
                    }
                    // se tiver selecionado a terceira opcao
                    else if (opçao == 2)
                    {
                        // atualiza a opcao para voltar para a primeira, antes de passar para a proxima tela
                        opçao = 0;
                        // atualiza esses booleans para passar para a tela de instrucoes
                        menuInicial = false, lendoInstruçoes = true;
                    }
                }
                // se estiver na tela de ler as intruções
                else if (lendoInstruçoes)
                {
                    // atualiza a opcao para voltar para a terceira opcao, antes de voltar para a tela anterior
                    opçao = 2;
                    // atualiza esses booleans para voltar a tela anterior
                    lendoInstruçoes = false, menuInicial = true;
                }
                // se estiver no meio do jogo
                else if (jogando)
                    // se voce tiver selecionado a primeira opcao
                    if (opçao == 0)
                        // atualiza esses booleans para voltar ao menu inicial
                        jogando = false, menuInicial = true;
                    // se voce tiver selecionado outra opcao
                    else
                    {
                        // armazena a resposta no array 'respostas'
                        respostas[cenarioAtual++] = opçao;

                        // se estiver no ultimo cenario
                        if (cenarioAtual == 6)
                        {
                            // coloca a opcao como a primeira, antes de passar para a proxima tela
                            opçao = 0;
                            // atualiza esses booleans para passar para a tela final do jogo
                            jogando = false, telaFinal = true;
                        }
                    }
                // se estiver na tela final
                else if (telaFinal)
                    // atualiza esses booleans para voltar ao menu inicial
                    telaFinal = false, menuInicial = true;
            }
    });
}
