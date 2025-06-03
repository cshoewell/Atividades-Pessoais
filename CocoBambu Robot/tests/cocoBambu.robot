***Settings***
Documentation    Testes API Cocobambu
Resource  ../resources/cocoBambu.resource


***Keywords***



***Test Cases***
# Suíte: Autenticação
Cenario 01: Token de autenticacao
    Criar Sessao na API
    Verificar status code e json valido    200    200      
    Salvar token de autenticaçao   ${AUTH_TOKEN}
    Construir cabeçalho de autenticaçao
    Construir cabeçalho content-type json
 
Cenario 02: Usuario
    Cadastrar novo usuario com sucesso
    Logar usuario com sucesso
    Recuperar senha de usuario com sucesso
    Ver perfil do usuario
    Atualizar perfil do usuario
    Listar endereços do usuario
    Adicionar novo endereço ao perfil
    Deletar usuario
    Atualizar endereço do usuario
    Deletar endereço do usuario

Cenario 03: Restaurantes
    Listar restaurantes disponiveis por localizaçao
    Obter detalhes de um restaurante especifico

Cenario 04: Cardapio
    Listar itens do cardapio de um restaurante
    Obter detalhes de um item do cardapio

Cenario 05: Pedidos
    Criar pedido (Checkout)
    Listar pedidos do usuario
    Obter detalhes de um pedido
    Cancelar pedido
    Reabrir pedido

Cenario 06: Carrinho
    Adicionar item ao carrinho
    Ver carrinho de compras
    Atualizar carrinho com merge de produtos
    Deletar carrinho