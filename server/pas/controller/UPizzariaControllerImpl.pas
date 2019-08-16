unit UPizzariaControllerImpl;

interface

{$I dmvcframework.inc}

uses  MVCFramework,
      MVCFramework.Logger,
      MVCFramework.Commons,
      Web.HTTPApp,
      UPizzaTamanhoEnum,
      UPizzaSaborEnum,
      UEfetuarPedidoDTOImpl,
      UPedidoRetornoDTOImpl,
      UPedidoServiceIntf;

type

  [MVCDoc('Pizzaria backend')]
  [MVCPath('/')]
  TPizzariaBackendController = class(TMVCController)
  public

    [MVCDoc('Criar novo pedido "201: Created"')]
    [MVCPath('/efetuarPedido')]
    [MVCHTTPMethod([httpPOST])]
    procedure efetuarPedido(const AContext: TWebContext);

    [MVCDoc('Consultar pedido "200: OK"')]
    [MVCPath('/consultarPedido/($documento)')]
    [MVCHTTPMethod([httpGET])]
    procedure consultarPedido(const AContext: TWebContext);

  end;

implementation

uses
  System.SysUtils,
  Rest.json,
  MVCFramework.SystemJSONUtils,
  UPedidoServiceImpl;

{ TApp1MainController }

procedure TPizzariaBackendController.consultarPedido(const AContext: TWebContext);
var
    oPedidoRetornoDTO: TPedidoRetornoDTO;
    oDocumento       : string;
    oPedidoService   : IPedidoService;
begin
  oDocumento := AContext.Request.Params['documento'];
  oPedidoService := TPedidoService.Create;

  TRY
    oPedidoRetornoDTO := oPedidoService.consultarPedido(oDocumento);
    Render(TJson.ObjectToJsonString(oPedidoRetornoDTO));
    oPedidoRetornoDTO.Free;
  except
    On E : Exception do
    begin
      AContext.Response.StatusCode := HTTP_Status.NotFound;
      Render(e.Message);
    end;
  END;

  Log.Info('==>Executou o método ', 'consultarPedido');
end;

procedure TPizzariaBackendController.efetuarPedido(const AContext: TWebContext);
var
  oEfetuarPedidoDTO: TEfetuarPedidoDTO;
  oPedidoRetornoDTO: TPedidoRetornoDTO;
  oBody : string;
begin
  oBody := AContext.Request.Body;
  oEfetuarPedidoDTO := TJson.JsonToObject<TEfetuarPedidoDTO>(oBody);
  try
    with TPedidoService.Create do
      try
        oPedidoRetornoDTO := efetuarPedido(oEfetuarPedidoDTO.PizzaTamanho, oEfetuarPedidoDTO.PizzaSabor, oEfetuarPedidoDTO.DocumentoCliente);
        Render(TJson.ObjectToJsonString(oPedidoRetornoDTO));
      finally
        oPedidoRetornoDTO.Free
      end;
  finally
    oEfetuarPedidoDTO.Free;
  end;
  Log.Info('==>Executou o método ', 'efetuarPedido');
end;

end.
