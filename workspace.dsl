workspace "Sistema Banco Center" "C4 Model - Sistema de Pagamentos" {

    model {

        # PESSOAS E SISTEMAS EXTERNOS

        usuario = person "Usuário" "Cliente que consulta saldo e realiza pagamentos."

        sistemaExterno = softwareSystem "Sistema Externo" "Sistema externo que representa integrações com serviços financeiros, como bancos ou o Banco Central. Responsável por validar, processar e liquidar transações." "External"

        # SISTEMA PRINCIPAL

        bancoCenterSystem = softwareSystem "Sistema Banco Center" "Sistema de internet banking que permite ao usuário consultar saldo e realizar pagamentos." {

            # CONTAINERS (Nível 2)

            staticContent = container "Static Content" "Serve os arquivos estáticos da aplicação web e mobile." "App Web / Mobile React Native" "Browser"

            ui = container "UI" "Single-page app que provê funcionalidades de internet banking ao cliente via navegador web." "React Native / Web SPA" "Browser"

            backend = container "Backend" "Servidor de aplicação responsável pela lógica de negócio e exposição da API REST." "Spring Boot / API REST" {

                # COMPONENTS (Nível 3)

                autenticacaoService = component "Autenticação Service" "Realiza autenticação e autorização de usuários por meio de tokens JWT assinados. Intercepta requisições HTTP, validando identidade, integridade e permissões. Funciona como camada de segurança que controla o acesso aos serviços de negócio." "Spring Security / JWT"

                transacaoService = component "Transação Service" "Executa a operação financeira propriamente dita, sendo responsável pela persistência dos dados e integração com sistemas externos, garantindo consistência e confiabilidade da transação." "Spring Service"

                saldoService = component "Saldo Service" "Application Service responsável por orquestrar o fluxo de execução das operações financeiras, centralizando a lógica de negócio de alto nível." "Spring Service"

                transferenciaService = component "Transferência Service" "Serviço de domínio responsável por encapsular a lógica de verificação e cálculo de saldo, garantindo integridade e consistência das operações financeiras." "Spring Service"
            }

            queue = container "Queue" "Fila de mensagens para processamento assíncrono de eventos financeiros." "RabbitMQ" "Queue"

            database = container "Database" "Armazena informações da conta do usuário, logs de acesso e dados transacionais." "PostgreSQL / MySQL" "Database"
        }

        # RELACIONAMENTOS - CONTEXTO (Nível 1)

        usuario -> bancoCenterSystem "Consulta saldo e realiza pagamentos"
        bancoCenterSystem -> sistemaExterno "Processa pagamento"
        sistemaExterno -> usuario "Valida CPF"

        # RELACIONAMENTOS - CONTAINERS (Nível 2)

        usuario -> staticContent "Loads the UI from"
        usuario -> ui "View account balance and make payments"
        ui -> backend "Faz requisições HTTP/REST"
        backend -> queue "Reads from and writes to"
        backend -> database "Reads from and writes to"
        backend -> sistemaExterno "Processa pagamento"
        sistemaExterno -> bancoCenterSystem "Valida CPF"

        # RELACIONAMENTOS - COMPONENTES (Nível 3)

        ui -> autenticacaoService "Envia requisições autenticadas"
        autenticacaoService -> transacaoService "Autoriza e repassa requisição"
        transacaoService -> saldoService "Orquestra operação financeira"
        transacaoService -> transferenciaService "Delega lógica de transferência"
        transacaoService -> sistemaExterno "Integra com sistema externo para liquidar transação"
        saldoService -> database "Lê e escreve dados"
    }

    # VIEWS

    views {

        # Nível 1 - Contexto
        systemContext bancoCenterSystem "Contexto" {
            include *
            autoLayout tb
            title "Diagrama de Contexto - Sistema Banco Center"
            description "Visão geral do sistema e seus atores externos."
        }

        # Nível 2 - Containers
        container bancoCenterSystem "Containers" {
            include *
            autoLayout tb
            title "Diagrama de Containers - Sistema Banco Center"
            description "Principais containers que compõem o sistema."
        }

        # Nível 3 - Componentes do Backend
        component backend "Componentes" {
            include *
            autoLayout tb
            title "Diagrama de Componentes - Backend"
            description "Componentes internos do container Backend."
        }

        # Nível 4 - Código (Classes)
        # Representado como diagrama de deployment/dynamic para o fluxo Saga
        dynamic bancoCenterSystem "Codigo" "Fluxo de Pagamento com Padrão Saga" {
            title "Diagrama de Código - Fluxo Saga de Pagamento"
            description "Sequência de operações no padrão Saga para garantir consistência distribuída."

            usuario -> backend "Inicia requisição de pagamento"
            backend -> sistemaExterno "1. solicita_reserva → Banco_Origem_System"
            backend -> database "2. documenta_tentativa_débito → Banco_de_Dados_de_Logs"
            backend -> sistemaExterno "3. tenta_depósito → Banco_Destino_System (FAIL_HERE)"
            backend -> sistemaExterno "4. executa_compensação → Banco_Origem_System"
            backend -> database "5. documenta_reversão → Banco_de_Dados_de_Logs"
            autoLayout tb
        }

        # Estilo visual
        styles {
            element "Person" {
                shape Person
                background #1168bd
                color #ffffff
                fontSize 22
            }
            element "Software System" {
                background #1168bd
                color #ffffff
            }
            element "External" {
                background #999999
                color #ffffff
            }
            element "Container" {
                background #438dd5
                color #ffffff
            }
            element "Component" {
                background #85bbf0
                color #000000
            }
            element "Database" {
                shape Cylinder
                background #438dd5
                color #ffffff
            }
            element "Queue" {
                shape Pipe
                background #438dd5
                color #ffffff
            }
            element "Browser" {
                shape WebBrowser
            }
        }
    }
}
