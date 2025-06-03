Desafio Técnico - Garantindo a Qualidade no Coco Bambu!

Este desafio tem como objetivo principal assegurar uma experiência de usuário de alta qualidade na plataforma de delivery do CocoBambu, identificando fluxos críticos de usuário, desenvolvendo testes de UI automatizados e validando as funcionalidades da API do carrinho. Ele visa atender a todos os requisitos especificados e demonstrar um forte entendimento dos princípios e práticas de QA.

Para realizar tais objetivos foi utilizado a ferramenta Robot Framework no VSCode.
Como pode ser analisado, foi elaborado um plano de testes no Confluence, abrangendo a maioria das funcionalidades para garantir a melhor cobertura de testes.

Com tempo hábil poderiamos ter feito um mapa mental com estrutura da API e ainda criarmos um épico e suas histórias no Jira para já deixar organizado o retorno dos testes realizados.

O teste seria mais completo se pudesse ter acesso a documentação da API, mas já foi possível estruturar testes básicos, necessitando apenas de complementações.

Observações da análise prévia:
  LOGIN:
	-Para cadastrar não tem a opção de utilizar o google.
	-Para realizar login a função de utilizar conta do google não funciona (nenhuma das opções: Apple, Facebook e Google).
 PEDIDO
	-No momento de fechar pedido ele pede para acrescentar CPF e telefone, mas não atualiza no perfil. Porem puxa do perfil quando preenchido.

 Para realizar os testes é necessário ter o VSCode instalado em sua máquina com o plugin do Robot Framework
   1. Dentro do VSCode abrir a pasta 'CocoBambu Robot'.
   2. No arquivo 'cocoBambu.resource' será possível rodar os testes de forma individual ou por completo em sequência.
   3. Os resultados dos testes serão demonstrados no terminal do VSCode e ao final de cada testes será gerado um arquivo log que permitirá verificar passo a passo do testes.
