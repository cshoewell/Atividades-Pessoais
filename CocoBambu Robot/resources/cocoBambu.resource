***Settings***
Library    RequestsLibrary
Library    Collections
Library    String
Library    OperatingSystem

***Variables***
${BASE_URL}              https://app-hom.cocobambu.com/delivery
${CONTENT_TYPE_JSON}     application/json
${AUTH_TOKEN}            ${EMPTY}  # Será preenchido após o login
${USER_ID}               ${EMPTY}  # Exemplo, se o ID do usuário vier na resposta do login
${RESTAURANT_ID}         defaultRestaurantId  # ID de um restaurante para testes
${MENU_ITEM_ID}          defaultMenuItemId    # ID de um item do cardápio para testes
${CART_ID}               ${EMPTY}  # ID do carrinho, se aplicável
${CART_ITEM_ID}          defaultCartItemId    # ID de um item dentro do carrinho
${ORDER_ID}              defaultOrderId       # ID de um pedido para testes
${ADDRESS_ID}            defaultAddressId     # ID de um endereço para testes
${BASE_URL_DUMMY}        https://dummyjson.com
${ADD_CART_URI}          /carts/add
${USER_ID_DUMMY}               ${1}
${CART_ID_TO_UPDATE}     ${1}
${UPDATE_CART_URI}       /carts/${CART_ID_TO_UPDATE}     # URI para atualizar o carrinho com ID específico
${CART_ID_TO_DELETE}     ${1}
${DELETE_CART_URI}       /carts/${CART_ID_TO_DELETE} # URI para deletar o carrinho com ID específico

***Keywords***
Criar sessao na API
    Create Session    cocobambuapi    ${BASE_URL}

Verificar status code e json valido
    [Arguments]    ${response}    ${expected_status_code}
    Status Should Be    200    ${response}    ${expected_status_code}
    Should Not Be Empty    ${response.content}    msg=Resposta da API está vazia.
    ${json_response} =  Evaluate    $response.json() if $response.content else None
    Should Not Be Equal As Strings    ${json_response}    ${None}    msg=A resposta não é um JSON válido ou está vazia.
    [Return]    ${json_response}

Salvar token de autenticaçao
    [Arguments]    ${json_response}
    ${access_token} =    Get Variable Value    ${json_response}    $.access_token
    Should Not Be Empty    ${access_token[0]}    msg=Access token não encontrado na resposta.
    Set Suite Variable    \${AUTH_TOKEN}    ${access_token[0]}
    Log    Token de autenticação salvo: ${AUTH_TOKEN}
    # Exemplo para salvar o User ID se ele vier na resposta do login
    # ${user_id_list}=    Get Value From Json    ${json_response}    $.user.id
    # IF    ${user_id_list}
    #     Set Suite Variable    \${USER_ID}    ${user_id_list[0]}
    #     Log    User ID salvo: ${USER_ID}
    # END

Construir cabeçalho de autenticaçao
    ${auth_header} =    Create Dictionary    Authorization=Bearer ${AUTH_TOKEN}    Content-Type=${CONTENT_TYPE_JSON}
    [Return]    ${auth_header}

Construir cabeçalho content-type json
    ${header} =    Create Dictionary    Content-Type=${CONTENT_TYPE_JSON}
    [Return]    ${header}


Logar usuario com sucesso
    [Tags]    Autenticacao    Login    Sucesso
    &{payload}    Create Dictionary
    ...           email=usuario@example.com
    ...           senha=suaSenha123
    ${headers}    Create Dictionary
    ...           Content-Type JSON
    ${response}    POST On Session    cocobambuapi    /auth/login    json=${payload}    headers=${headers}

    ${json_response}    Status Should Be   ${response}    200
    [Return]    ${json_response}
    

Recuperar senha de usuario com sucesso
    [Tags]    Autenticacao    RecuperarSenha    Sucesso
    &{payload}=    Create Dictionary    email=usuario_esquecido_robot@example.com
    ${headers}=    Create Dictionary    Content-Type=${CONTENT_TYPE_JSON}
    ${response}=    POST On Session    cocobambuapi    /auth/forgot-password    json=${payload}    headers=${headers}

    Should Be True    ${response.status_code} == 200 or ${response.status_code} == 204    msg=Status code esperado 200 ou 204, mas foi ${response.status_code}
    IF    ${response.status_code} == 200
        ${json_response}=    Status Should Be    ${response}    200
        ${message_list}=    Get Variable Value    ${json_response}    $.message
        Should Not Be Empty    ${message_list[0]}    msg=Mensagem não encontrada na resposta.
        Should Contain    ${message_list[0]}    instruções foram enviadas
    END

Cadastrar novo usuario com sucesso    
    [Tags]    Autenticacao    Cadastro    Sucesso
    &{payload}=    Create Dictionary
    ...    nome=Novo Usuário Teste Robot
    ...    email=novo_usuario_robot@example.com
    ...    senha=senhaForteRobot123!
    ...    telefone=11999997777
    ${headers}=    Create Dictionary    Content-Type=${CONTENT_TYPE_JSON}
    [Return]    ${auth_header}
    ${response}=    POST On Session    cocobambuapi    /auth/register    json=${payload}    headers=${headers}

    ${json_response}=    Status Should Be    ${response}    201
    ${user_id_list}=    Get Variable Value    ${json_response}    $.id
    Should Not Be Empty    ${user_id_list[0]}    msg=ID do usuário não encontrado na resposta.
    ${email_list}=    Get Variable Value    ${json_response}    $.email
    Should Be Equal As Strings    ${email_list[0]}    novo_usuario_robot@example.com

Ver perfil do usuario
    # Obtém os dados do perfil do usuário autenticado. 
    [Tags]    Perfil    VerPerfil    Sucesso
    Skip If    '${AUTH_TOKEN}' == '${EMPTY}'    Requer autenticação.
    ${headers}=    ${auth_header}
    Remove From Dictionary    ${headers}    Content-Type
    ${response}=    GET On Session    cocobambuapi    /profile    headers=${headers}

    ${json_response}=    Status Should Be    ${response}    200
    ${id_list}=    Get Variable Value    ${json_response}    $.id
    Should Not Be Empty    ${id_list[0]} # Comparar com ${USER_ID} se estiver salvo
    ${name_list}=    Get Variable Value   ${json_response}    $.name
    Should Be String    ${name_list[0]}
    ${email_list}=   Get Variable Value    ${json_response}    $.email
    Should Be String    ${email_list[0]}

Atualizar perfil do usuario
    #Atualiza os dados do perfil do usuário autenticado.
    [Tags]    Perfil    AtualizarPerfil    Sucesso
    Skip If    '${AUTH_TOKEN}' == '${EMPTY}'    Requer autenticação.
    &{payload}=    Create Dictionary    name=Nome Atualizado Robot    phone=11977776666
    ${headers}=    ${auth_header}
    ${response}=    PUT On Session    cocobambuapi    /profile    json=${payload}    headers=${headers}

    ${json_response}=    Status Should Be    ${response}    200
    ${name_list}=    Get Variable Value    ${json_response}    $.name
    Should Be Equal As Strings    ${name_list[0]}    Nome Atualizado Robot

Listar endereços do usuario
    #Lista os endereços cadastrados pelo usuário.
    [Tags]    Perfil    ListarEnderecos    Sucesso
    Skip If    '${AUTH_TOKEN}' == '${EMPTY}'    Requer autenticação.
    ${headers}=    ${auth_header}
    Remove From Dictionary    ${headers}    Content-Type
    ${response}=    GET On Session    cocobambuapi    /profile/addresses    headers=${headers}

    ${json_response}=    Status Should Be    ${response}    200
    Should Not Be Empty    ${json_response}
    IF    len($json_response) > 0
        FOR    ${address}    IN    @{json_response}
            Dictionary Should Contain Key    ${address}    id
            Dictionary Should Contain Key    ${address}    street
            Should Be String    ${address}[street]
        END
    END

Adicionar novo endereço ao perfil
    #Adiciona um novo endereço para o usuário.
    [Tags]    Perfil    AdicionarEndereco    Sucesso
    Skip If    '${AUTH_TOKEN}' == '${EMPTY}'    Requer autenticação.
    &{payload}=    Create Dictionary
    ...    street=Rua Nova Robot Teste
    ...    number=200
    ...    complement=Bloco B
    ...    neighborhood=Bairro Robot
    ...    city=Cidade Robot
    ...    state=RJ
    ...    zip_code=02000-000
    ...    is_default=${FALSE}
    ...    label=Trabalho
    ${headers}=    ${auth_header}
    ${response}=    POST On Session    cocobambuapi    /profile/addresses    json=${payload}    headers=${headers}

    ${json_response}=    Status Should Be    ${response}    201
    ${id_list}=    Get Variable Value    ${json_response}    $.id
    Should Not Be Empty    ${id_list[0]}
    ${street_list}=    Get Variable Value    ${json_response}    $.street
    Should Be Equal As Strings    ${street_list[0]}    Rua Nova Robot Teste

Deletar usuario
    [Tags]    Perfil    DeletarUsuario    Sucesso
    Skip If    '${AUTH_TOKEN}' == '${EMPTY}'    Requer autenticação.
    ${headers}=    ${auth_header}
    Remove From Dictionary    ${headers}    Content-Type
    ${response}=    DELETE On Session    cocobambuapi    /profile    headers=${headers}

    Should Be True    ${response.status_code} == 200 or ${response.status_code} == 204
    IF    ${response.status_code} == 200
        Status Should Be    ${response}    200
        # Adicionar verificações se a resposta contiver o usuário deletado
    END

Atualizar endereço do usuario
    [Tags]    Perfil    AtualizarEndereco    Sucesso
    Skip If    '${AUTH_TOKEN}' == '${EMPTY}'    Requer autenticação.
    Skip If    '${ADDRESS_ID}' == 'defaultAddressId'    Requer um ID de endereço válido.
    &{payload}=    Create Dictionary
    ...    street=Rua Atualizada Robot Teste
    ...    number=300
    ...    complement=Apto 101
    ...    neighborhood=Bairro Atualizado Robot
    ...    city=Cidade Atualizada Robot
    ...    state=SP
    ...    zip_code=03000-000
    ...    is_default=${FALSE}
    ${headers}=    ${auth_header}
    ${response}=    PUT On Session    cocobambuapi    /profile/addresses/${ADDRESS_ID}    json=${payload}    headers=${headers}

    ${json_response}=   Status Should Be   ${response}   200
    ${id_list}=   Get Variable Value   ${json_response}   $.id
    Should Not Be Empty   ${id_list[0]}
    ${street_list}=   Get Variable Value   ${json_response}   $.street
    Should Be Equal As Strings   ${street_list[0]}   Rua Atualizada Robot Teste

Deletar endereço do usuario
    [Tags]    Perfil    DeletarEndereco    Sucesso
    Skip If    '${AUTH_TOKEN}' == '${EMPTY}'    Requer autenticação.
    Skip If    '${ADDRESS_ID}' == 'defaultAddressId'    Requer um ID de endereço válido.
    ${headers}=    ${auth_header}
    Remove From Dictionary    ${headers}    Content-Type
    ${response}=    DELETE On Session    cocobambuapi    /profile/addresses/${ADDRESS_ID}    headers=${headers}

    Should Be True    ${response.status_code} == 200 or ${response.status_code} == 204
    IF    ${response.status_code} == 200
        Status Should Be   ${response}   200
        # Adicionar verificações se a resposta contiver o endereço deletado
    END


# Suíte: Restaurantes/Lojas
Listar restaurantes disponiveis por localizaçao
    Create Session    cocobambuapi    ${BASE_URL}   
    [Tags]    Restaurantes    Listagem    Sucesso    
    ${params}=    Create Dictionary    latitude=-23.550520    longitude=-46.633308
    ${response}=    GET On Session
    ...    cocobambuapi
    ...    /restaurants
    ...    params=${params}

    ${json_response}=    Status Should Be    ${response}    200
    Should Not Be Empty    ${json_response}
    IF    len($json_response) > 0
        FOR    ${restaurant}    IN    @{json_response}
            Dictionary Should Contain Key    ${restaurant}    id
            Dictionary Should Contain Key    ${restaurant}    name
            Should Be String    ${restaurant}[name]
        END
        Set Suite Variable    \${RESTAURANT_ID}    ${json_response[0]['id']} # Salva o ID do primeiro para testes subsequentes
        Log    ID do Restaurante para próximos testes: ${RESTAURANT_ID}
    END

Obter detalhes de um restaurante especifico
    Create Session    cocobambuapi    ${BASE_URL}
    [Tags]    Restaurantes    Detalhes    Sucesso
    Skip If    '${RESTAURANT_ID}' == 'defaultRestaurantId'    É necessário um ID de restaurante válido. Execute 'Listar Restaurantes Disponíveis' primeiro.
    ${response}=    GET On Session
    ...    cocobambuapi
    ...    /restaurants/${RESTAURANT_ID}

    ${json_response}=    Status Should Be    ${response}    200
    ${id_list}=    Get Variable Value    ${json_response}    $.id
    Should Be Equal As Strings    ${id_list[0]}    ${RESTAURANT_ID}
    ${name_list}=    Get Variable Value    ${json_response}    $.name
    Should Be String    ${name_list[0]}
    ${address_list}=    Get Variable Value    ${json_response}    $.address
    Should Be String    ${address_list[0]}


# Suíte: Cardápio
Listar itens do cardapio de um restaurante
    #Obtém o cardápio completo de um restaurante específico.
    Create Session    cocobambuapi    ${BASE_URL}
    [Tags]    Cardapio    Listagem    Sucesso
    Skip If    '${RESTAURANT_ID}' == 'defaultRestaurantId'    É necessário um ID de restaurante válido.
    ${response}=    GET On Session
    ...    cocobambuapi
    ...    /restaurants/${RESTAURANT_ID}/menu

    ${json_response}=    Status Should Be    ${response}    200
    ${categories_list}=    Get Variable Value    ${json_response}    $.categories
    Should Be Equal As Strings    (${categories_list[0]})    ${None}    msg=O cardápio não contém categorias válidas.
    IF    len($categories_list[0]) > 0 and len($categories_list[0][0]['items']) > 0
        ${first_item}=    Set Variable    ${categories_list[0][0]['items'][0]}
        Dictionary Should Contain Key    ${first_item}    id
        Dictionary Should Contain Key    ${first_item}    name
        Should Be String    ${first_item}[name]
        Dictionary Should Contain Key    ${first_item}    price
        Should Be Equal As Numbers    (${first_item}[price])   ${None}    msg=O preço do item não é válido.
        Set Suite Variable    \${MENU_ITEM_ID}    ${first_item}[id]
        Log    ID do Item de Menu para próximos testes: ${MENU_ITEM_ID}
    END

Obter detalhes de um item do cardapio
    #Obtém os detalhes de um item específico do cardápio.
    [Tags]    Cardapio    Detalhes    Sucesso
    Skip If    '${MENU_ITEM_ID}' == 'defaultMenuItemId'    É necessário um ID de item de menu válido.
    ${response}=    GET On Session    cocobambuapi    /menu-items/${MENU_ITEM_ID}

    ${json_response}=    Status Should Be    ${response}    200
    ${id_list}=    Get Variable Value    ${json_response}    $.id
    Should Be Equal As Strings    ${id_list[0]}    ${MENU_ITEM_ID}
    ${name_list}=    Get Variable Value    ${json_response}    $.name
    Should Be String    ${name_list[0]}
    ${price_list}=    Get Variable Value    ${json_response}    $.price
    Should Not Be Empty    ${price_list[0]}     ${json_response}
    ${description_list}=    Get Variable Value    ${json_response}    $.description
    Should Be String    ${description_list[0]}

# Suíte: Carrinho de Compras
Adicionar item ao carrinho
    Create Session    dummyapi    ${BASE_URL_DUMMY}

    &{headers}=       Create Dictionary    Content-Type=application/json
    &{product1}=      Create Dictionary    id=${144}    quantity=${4}
    &{product2}=      Create Dictionary    id=${98}     quantity=${1}
    @{products_list}=  Create List          ${product1}    ${product2}

    &{payload}=       Create Dictionary
    ...    userId=${USER_ID_DUMMY}
    ...    products=${products_list}

    ${response}=      POST On Session
    ...    dummyapi                      
    ...    ${ADD_CART_URI}               
    ...    json=${payload}               # Corpo da requisição (será convertido para JSON)
    ...    headers=${headers}            # Cabeçalhos

    Should Be Equal As Strings    ${response.status_code}    201  
    Log To Console    \nResposta da API:
    Log To Console    ${response.json()}
    ${response_body_json}=    Set Variable    ${response.json()}
    Log    Resposta completa: ${response_body_json}

    Should Contain     ${response_body_json}    id
    ${cart_id}=    Get From Dictionary    ${response_body_json}    id
    Log To Console    ID do Carrinho: ${cart_id}
    ${added_products}=    Get From Dictionary    ${response_body_json}    products
    Length Should Be    ${added_products}    2


Ver carrinho de compras
    [Tags]    Carrinho    VerCarrinho    Sucesso
    Skip If    '${AUTH_TOKEN}' == '${EMPTY}'    Requer autenticação.
    ${headers}=    ${auth_header}
    Remove From Dictionary    ${headers}    Content-Type  # GET não precisa de Content-Type no header geralmente
    ${response}=    GET On Session    cocobambuapi    /cart    headers=${headers}

    ${json_response}=    Status Should Be    ${response}    200
    ${items_list}=    Get Variable Value    ${json_response}    $.items
    Should Not Be Empty    ${items_list[0]}
    ${total_price_list}=    Get Variable Value    ${json_response}    $.total_price
    Should Be Equal As Strings    ${total_price_list[0]}    ${json_response}    $.total_price

Atualizar carrinho com merge de produtos
    # Criar uma sessão para a API
    Create Session    dummyapi    ${BASE_URL_DUMMY}

    &{headers}=       Create Dictionary    Content-Type=application/json
    # Definir o produto a ser adicionado/atualizado no carrinho
    &{product_to_add}=    Create Dictionary    id=${1}    quantity=${1}
    @{products_for_update}=  Create List        ${product_to_add}

    # Inclui o parâmetro 'merge' como booleano ${True}
    &{payload}=       Create Dictionary
    ...    merge=${True}
    ...    products=${products_for_update}

    ${response}=      PUT On Session
    ...    dummyapi                       
    ...    ${UPDATE_CART_URI}             
    ...    json=${payload}                # Corpo da requisição (será convertido para JSON)
    ...    headers=${headers}             # Cabeçalhos

    Should Be Equal As Strings    ${response.status_code}    200
   
    Log To Console    \nResposta da API (Atualização do Carrinho):
    Log To Console    ${response.json()}
    ${updated_cart_data}=    Set Variable    ${response.json()}
    Log    Corpo da resposta completo: ${updated_cart_data}

    Should Contain    ${updated_cart_data}    products
    ${updated_products_list}=    Get From Dictionary    ${updated_cart_data}    products
    # Verificar se o produto com id 1 e quantity 1 está na lista, 
    # e se outros produtos (se existiam e merge=true) ainda estão lá.
    Log To Console    Produtos no carrinho atualizado: ${updated_products_list}

Deletar carrinho
    Create Session    dummyapi    ${BASE_URL_DUMMY}

    ${response}=      DELETE On Session
    ...    dummyapi                      
    ...    ${DELETE_CART_URI}            

    Should Be Equal As Strings    ${response.status_code}    200
    Log To Console    \nResposta da API (Deleção do Carrinho):
    Log To Console    ${response.json()}

    ${deleted_cart_info}=    Set Variable    ${response.json()}
    Log    Corpo da resposta completo: ${deleted_cart_info}

    # Verificar se o carrinho foi marcado como deletado e se o ID corresponde
    # A API dummyjson.com adiciona uma flag "isDeleted: true" ao objeto retornado
    Should Contain      ${deleted_cart_info}    isDeleted
    ${is_deleted_flag}=     Get From Dictionary     ${deleted_cart_info}    isDeleted
    Should Be True          ${is_deleted_flag}
    Should Contain      ${deleted_cart_info}    id
    ${returned_id}=         Get From Dictionary     ${deleted_cart_info}    id
    Should Be Equal As Integers    ${returned_id}    ${CART_ID_TO_DELETE}
    Log To Console    Carrinho ID: ${returned_id} foi marcado como deletado.

# Suíte: Pedidos
Criar pedido (Checkout)
    #Finaliza a compra e cria um novo pedido.
    [Tags]    Pedidos    CriarPedido    Checkout    Sucesso
    Skip If    '${AUTH_TOKEN}' == '${EMPTY}'    Requer autenticação.
    # Skip If    '${CART_ID}' == '${EMPTY}'    Requer um cartId válido, ou a API infere pelo usuário.
    &{payment_details}=    Create Dictionary    card_token=tok_xxxxxxxxxxxxxx_robot    installments=${1}
    &{payload}=    Create Dictionary
    ...    cart_id=${CART_ID} # Ou remover se a API inferir
    ...    address_id=user_address_id_robot_123
    ...    payment_method=CREDIT_CARD
    ...    payment_details=${payment_details}
    ...    delivery_notes=Deixar na portaria com Sr. José (Robot).
    ${headers}=    ${auth_header}
    ${response}=    POST On Session    cocobambuapi    /orders    json=${payload}    headers=${headers}

    ${json_response}=    Status Should Be    ${response}    201
    ${order_id_list}=    Get Variable Value    ${json_response}    $.order_id
    Should Not Be Empty    ${order_id_list[0]}    msg=Order ID não encontrado.
    Set Suite Variable    \${ORDER_ID}    ${order_id_list[0]}
    Log    Order ID criado: ${ORDER_ID}
    ${status_list}=    Get Variable Value    ${json_response}    $.status
    Should Be Equal As Strings    ${status_list[0]}    RECEIVED # Ou o status inicial esperado

Listar pedidos do usuario
    #Lista todos os pedidos realizados pelo usuário autenticado.
    [Tags]    Pedidos    ListarPedidos    Sucesso
    Skip If    '${AUTH_TOKEN}' == '${EMPTY}'    Requer autenticação.
    ${headers}=    ${auth_header}
    Remove From Dictionary    ${headers}    Content-Type
    ${response}=    GET On Session    cocobambuapi    /orders    headers=${headers}

    ${json_response}=    Status Should Be    ${response}    200
    Should Not Be Empty    ${json_response}
    IF    len($json_response) > 0
        FOR    ${order}    IN    @{json_response}
            Dictionary Should Contain Key    ${order}    order_id
            Dictionary Should Contain Key    ${order}    status
            Should Be String    ${order}[status]
        END
    END

Obter detalhes de um pedido
    #Obtém os detalhes de um pedido específico.
    [Tags]    Pedidos    DetalhesPedido    Sucesso
    Skip If    '${AUTH_TOKEN}' == '${EMPTY}'    Requer autenticação.
    Skip If    '${ORDER_ID}' == 'defaultOrderId'    Requer um orderId válido.
    ${headers}=    ${auth_header}
    Remove From Dictionary    ${headers}    Content-Type
    ${response}=    GET On Session    cocobambuapi    /orders/${ORDER_ID}    headers=${headers}

    ${json_response}=    Status Should Be    ${response}    200
    ${id_list}=    Get Variable Value    ${json_response}    $.order_id
    Should Be Equal As Strings    ${id_list[0]}    ${ORDER_ID}
    ${status_list}=    Get Variable Value    ${json_response}    $.status
    Should Not Be Empty    ${status_list[0]}
    ${items_list}=    Get Variable Value    ${json_response}    $.items
    Should Be Equal As Strings   ${items_list[0]}    ${json_response}    $.items

Cancelar pedido
    #Cancela um pedido específico.
    [Tags]    Pedidos    CancelarPedido    Sucesso
    Skip If    '${AUTH_TOKEN}' == '${EMPTY}'    Requer autenticação.
    Skip If    '${ORDER_ID}' == 'defaultOrderId'    Requer um orderId válido.
    ${headers}=    ${auth_header}
    Remove From Dictionary    ${headers}    Content-Type
    ${response}=    DELETE On Session    cocobambuapi    /orders/${ORDER_ID}    headers=${headers}

    Should Be True    ${response.status_code} == 200 or ${response.status_code} == 204
    IF    ${response.status_code} == 200
        Status Should Be   ${response}   200
        # Adicionar verificações se a resposta contiver o pedido cancelado
    END  

Reabrir pedido
    #Reabre um pedido cancelado.
    [Tags]    Pedidos    ReabrirPedido    Sucesso
    Skip If    '${AUTH_TOKEN}' == '${EMPTY}'    Requer autenticação.
    Skip If    '${ORDER_ID}' == 'defaultOrderId'    Requer um orderId válido.
    ${headers}=    ${auth_header}
    Remove From Dictionary    ${headers}    Content-Type
    ${response}=    POST On Session    cocobambuapi    /orders/${ORDER_ID}/reopen    headers=${headers}   
    Should Be True    ${response.status_code} == 200 or ${response.status_code} == 204
    IF    ${response.status_code} == 200
        ${json_response}=    Status Should Be   ${response}   200
        ${id_list}=    Get Variable Value    ${json_response}    $.order_id
        Should Be Equal As Strings    ${id_list[0]}    ${ORDER_ID}
        ${status_list}=    Get Variable Value    ${json_response}    $.status
        Should Be Equal As Strings    ${status_list[0]}    REOPENED # Ou o status esperado após reabertura
    END