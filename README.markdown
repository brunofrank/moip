MOIP
=========

Este é um plugin do Ruby on Rails que permite utilizar o gateway de pagamentos [MOIP](https://www.moip.com.br).


### Retorno Automático

Após o processo de compra e pagamento, o usuário é enviado de volta a seu site. Para isso, você deve configurar uma [URL de retorno](https://www.moip.com.br/AdmMainMenuMyData.do?method=transactionnotification).

Antes de enviar o usuário para essa URL, o robô do MOIP faz um POST para ela, em segundo plano, com os dados e status da transação. Lendo esse POST, você pode obter o status do pedido. Se o pagamento entrou em análise, ou se o usuário pagou usando boleto bancário, o status será "Aguardando Pagamento" ou "Em Análise". Nesses casos, quando a transação for confirmada (o que pode acontecer alguns dias depois) a loja receberá outro POST, informando o novo status. **Cada vez que a transação muda de status, um POST é enviado.**

COMO USAR
---------

### Configuração

O primeiro passo é instalar o plugin. Para isso, basta executar o comando abaixo na raíz de seu projeto.

	script/plugin install git://github.com/brunofrank/moip.git

Depois de instalar o plugin, você precisará executar a rake abaixo; ela irá gerar o arquivo `config/moip.yml`.

	rake moip:setup

O arquivo de configuração gerado será parecido com isto:

	development: &development
	  sandbox: true
	  email: user@example.com

	test:
	  <<: *development

	production:
	  email: user@example.com

Este plugin possui um modo sandbox que permite simular vendas; basta utilizar a opção `developer`. Ela é ativada por padrão nos ambientes de desenvolvimento e teste. Você deve configurar as opções `base`, que deverá apontar para o seu servidor e a URL de retorno, que deverá ser configurada no próprio [Moip](https://www.moip.com.br/), na página <https://www.moip.com.br/AdmMainMenuMyData.do?method=transactionnotification>, para isso você deve fazer o cadastro no [MoIP Sandbox](http://desenvolvedor.moip.com.br/sandbox/)

Para o ambiente de produção, que irá efetivamente enviar os dados para o [Moip](https://www.moip.com.br), você precisará adicionar o e-mail cadastrado como vendedor.

### Montando o formulário

Para montar o seu formulário, você deverá utilizar a classe `Moip::Order`. Esta classe deverá ser instanciada recebendo um identificador único do pedido. Este identificador permitirá identificar o pedido quando o [MOIP](https://www.moip.com.br) notificar seu site sobre uma alteração no status do pedido.

	class CartController < ApplicationController
	  def checkout
	    # Busca o pedido associado ao usuário; esta lógica deve
	    # ser implementada por você, da maneira que achar melhor
		@invoice = current_user.invoices.last

		# Instanciando o objeto para geração do formulário
	    @order = Moip::Order.new(@invoice.id)

	    # adicionando os produtos do pedido ao objeto do formulário
	    @invoice.products.each do |product|
	      # Estes são os atributos necessários. Por padrão, peso (:weight) é definido para 0,
		    # quantidade é definido como 1 e frete (:shipping) é definido como 0.
	      @order.add :id => product.id, :price => product.price, :description => product.title
	    end
	  end
	end

Se você precisar, pode definir o tipo de frete com o método `shipping_type`.

	@order.shipping_type = "SD" # Sedex
	@order.shipping_type = "EN" # PAC
	@order.shipping_type = "FR" # Frete Próprio

Depois que você definiu os produtos do pedido, você pode exibir o formulário.

	<!-- app/views/cart/checkout.html.erb -->
	<%= moip_form @order, :submit => "Efetuar pagamento!" %>

Por padrão, o formulário é enviado para o email no arquivo de configuração. Você pode mudar o email com a opção `:email`.

	<%= moip_form @order, :submit => "Efetuar pagamento!", :email => @account.email %>

### Recebendo notificações

Toda vez que o status de pagamento for alterado, o [MOIP](http://www.moip.com.br) irá notificar sua URL de retorno com diversos dados. Você pode interceptar estas notificações com o método `moip_notification`. O bloco receberá um objeto da class `Moip::Notification` e só será executado se for uma notificação verificada junto ao [MOIP](http://www.moip.com.br).

	class CartController < ApplicationController

	  def confirm
	    return unless request.post?

		moip_notification do |notification|
		  # Aqui você deve verificar se o pedido possui os mesmos produtos
		  # que você cadastrou. O produto só deve ser liberado caso o status
		  # do pedido seja "completed" ou "approved"
		end

		render :nothing => true
	  end
	end


O objeto `notification` possui os seguintes métodos:

* `Moip::Notification#products`: Lista de produtos enviados na notificação.
* `Moip::Notification#status`: Status do pedido
* `Moip::Notification#payment_method`: Tipo de pagamento
* `Moip::Notification#buyer`: Dados do comprador


#### PAYMENT_METHOD

* `credit_card`: Cartão de crédito
* `invoice`: Boleto
* `online_transfer`: Pagamento online
* `pagseguro`: Transferência entre contas do PagSeguro

#### STATUS

* `completed`: Completo
* `pending`: Aguardando pagamento
* `approved`: Aprovado
* `verifying`: Em análise
* `canceled`: Cancelado
* `refunded`: Devolvido

AUTOR:
------

Bruno Frank Silva Cordeiro

NOTA:
----

Este plugin é uma adaptação do [PagSeguro](https://github.com/fnando/pagseguro) do [Nando Vieira](http://simplesideias.com.br) 

LICENÇA:
--------

(The MIT License)

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.