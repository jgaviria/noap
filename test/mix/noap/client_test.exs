defmodule Noap.ClientTest do
  use ExUnit.Case
  import ExUnit.CaptureLog

  test "handle_Conversion_from_SOAP_failed_chex_500_error logs warning and returns {:error, 500, 'Conversion from SOAP failed'}" do
    xml_response = "<SOAP-ENV:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:tns=\"http://www.IDC52700.IDCC018.com\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:SOAP-ENV=\"http://schemas.xmlsoap.org/soap/envelope/\"><SOAP-ENV:Body><SOAP-ENV:Fault xmlns=\"\"><faultcode>SOAP-ENV:Server</faultcode><faultstring>Conversion from SOAP failed</faultstring><detail><CICSFault xmlns=\"http://www.ibm.com/software/htp/cics/WSFault\">DFHPI1009 07/18/2025 10:24:03 EFAEFSP1 ID57 41641 XML to data transformation failed. A conversion error (OUTPUT_OVERFLOW) occurred when converting field CustId for WEBSERVICE cav3.</CICSFault></detail></SOAP-ENV:Fault></SOAP-ENV:Body></SOAP-ENV:Envelope>"

    log =
      capture_log(fn ->
        result = Noap.Client.parse({:ok, 500, xml_response}, nil)
        assert result == {:error, 500, "Conversion from SOAP failed"}
      end)

    assert log =~ "Chex conversion from SOAP failed status_code"
  end
end