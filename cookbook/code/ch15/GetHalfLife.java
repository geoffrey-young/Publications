// Simple command line tool to retrieve HalfLife Information

import java.io.*;
import java.util.*;
import java.net.*;
import org.w3c.dom.*;
import org.xml.sax.*;
import javax.xml.parsers.*;
import org.apache.soap.util.xml.*;
import org.apache.soap.*;
import org.apache.soap.encoding.*;
import org.apache.soap.encoding.soapenc.*;
import org.apache.soap.rpc.*;
import org.apache.soap.transport.http.SOAPHTTPConnection;

public class GetHalfLife {
    public static final String DEFAULT_SERVICE_URL =
        "http://www.example.com/game-query";

    public static void main(String[] args) throws Exception {
        String serviceURL     = DEFAULT_SERVICE_URL;

        URL url = new URL(serviceURL);

        // create the transport and set parameters
        SOAPHTTPConnection st = new SOAPHTTPConnection();

        // build the call.
        Call call = new Call();
        call.setSOAPTransport(st);
        call.setTargetObjectURI("urn:HalfLife/QueryServer");
        call.setMethodName("remotequery");
        call.setEncodingStyleURI(Constants.NS_URI_SOAP_ENC);

        Vector params = new Vector();
        params.addElement(new Parameter("server", String.class,
                                        "10.3.4.200", null));
        call.setParams(params);

        // Send request to Halflife SOAP Server
        System.err.println("Invoking Halflife service at: ");
        System.err.println("\t" + serviceURL);

        Response resp;
        try {
            resp = call.invoke(url, "");
        } catch(SOAPException e) {
            System.err.println("Caught SOAPException (" +
                               e.getFaultCode () + "): " +
                               e.getMessage ());
            return;
        }

        // check response
        if (!resp.generatedFault()) {
            Parameter ret     = resp.getReturnValue();
            Object    value   = ret.getValue();
            String[]  results = (String[])value;
          
            // Print out the returned array of information.

            for (int i = 0; i < results.length; i++)
                    System.out.println(results[i] );

        } else {
            Fault fault = resp.getFault();
            System.err.println("Generated fault: ");
            System.out.println("  Fault Code   = " + fault.getFaultCode());
            System.out.println("  Fault String = " + fault.getFaultString());
        }
    }
}
