*** Settings ***

Documentation   Test OpenBMC GUI "SNMP Alerts" sub-menu of "Settings".

Resource        ../../lib/gui_resource.robot
Resource        ../../../lib/snmp/resource.robot
Resource        ../../../lib/snmp/redfish_snmp_utils.robot

Suite Setup     Suite Setup Execution
Suite Teardown  Close Browser


*** Variables ***

${xpath_snmp_alerts_sub_menu}                     //*[@data-test-id='nav-item-snmp-alerts']
${xpath_snmp_alerts_heading}                      //h1[text()="SNMP alerts"]
${xpath_select_all_snmp}                          //*[@data-test-id='snmpAlerts-checkbox-selectAll']
${xpath_add_destination}                          //button[contains(text(),'Add destination')]
${xpath_snmp_alert_destination_heading}           //h5[contains(text(),'Add SNMP alert destination')]
${xpath_ip_address_input_button}                  //*[@data-test-id='snmpAlerts-input-ipAddress']
${xpath_port_optional_input_button}               //*[@data-test-id='snmpAlerts-input-port']
${xpath_snmp_add_destination_button}              //*[@data-test-id='snmpAlerts-button-ok']
${xpath_cancel_button}                            //button[contains(text(),'Cancel')]
${xpath_delete_button}                            //*[@data-test-id='snmpAlerts-button-deleteRow-undefined']
${xpath_delete_destination}                       //button[contains(text(),'Delete destination')]

${snmp_page_heading}                              SNMP alerts
${invalid_port_error}                             Value must be between 0 – 65535
${invalid_destination_error}                      Error in adding SNMP alert destination


*** Test Cases ***

Verify Navigation To SNMP Alerts Page
    [Documentation]  Verify navigation to SNMP alerts page.
    [Tags]  Verify_Navigation_To_SNMP_Alerts_Page

    Page Should Contain Element  ${xpath_snmp_alerts_heading}


Verify Existence Of All Input Boxes In SNMP Alerts Page
    [Documentation]  Verify existence of all sections in SNMP alerts page.
    [Tags]  Verify_Existence_Of_All_Input_Boxes_In_SNMP_Alerts_Page

    Page Should Contain Checkbox  ${xpath_select_all_snmp}


Verify Existence Of All Buttons In SNMP Alerts Page
    [Documentation]  Verify existence of all buttons in SNMP alerts page.
    [Tags]  Verify_Existence_Of_All_Buttons_In_SNMP_Alerts_Page

    Page should Contain Button  ${xpath_add_destination}


Verify Existence Of All Fields In Add Destination
    [Documentation]  Verify existence of all buttons and fields in add destination page.
    [Tags]  Verify_Existence_Of_All_Fields_In_Add_Destination
    [Teardown]  Run Keywords  Click Button  ${xpath_cancel_button}  AND
    ...  Wait Until Keyword Succeeds  10 sec  5 sec
    ...  Refresh GUI And Verify Element Value  ${xpath_snmp_alerts_heading}  ${snmp_page_heading}

    Click Element  ${xpath_add_destination}
    Wait Until Page Contains Element  ${xpath_snmp_alert_destination_heading}
    Page Should Contain Element  ${xpath_ip_address_input_button}
    Page Should Contain Element  ${xpath_port_optional_input_button}
    Page Should Contain Element  ${xpath_cancel_button}
    Page Should Contain Element  ${xpath_snmp_add_destination_button}


Configure SNMP Settings On BMC With Non Default Port Via GUI And Verify
    [Documentation]  Configure SNMP settings on BMC with non default port via GUI and verify.
    [Tags]  Configure_SNMP_Settings_On_BMC_With_Non_Default_Port_Via_GUI_And_Verify
    [Teardown]  Delete SNMP Manager Via GUI  ${SNMP_MGR1_IP}  ${NON_DEFAULT_PORT1}

    Configure SNMP Manager Via GUI  ${SNMP_MGR1_IP}  ${NON_DEFAULT_PORT1}

    Wait Until Page Contains  ${SNMP_MGR1_IP}  timeout=45s

    Redfish.Login
    Verify SNMP Manager Configured On BMC  ${SNMP_MGR1_IP}  ${NON_DEFAULT_PORT1}
    Redfish.Logout

Configure SNMP Settings On BMC Via GUI And Verify
    [Documentation]  Configure SNMP settings on BMC via GUI and verify.
    [Tags]  Configure_SNMP_Settings_On_BMC_Via_GUI_And_Verify
    [Teardown]  Delete SNMP Manager Via GUI  ${SNMP_MGR1_IP}  ${SNMP_DEFAULT_PORT}

    Configure SNMP Manager Via GUI  ${SNMP_MGR1_IP}  ${SNMP_DEFAULT_PORT}

    Wait Until Page Contains  ${SNMP_MGR1_IP}  timeout=45s

    Verify SNMP Manager Configured On BMC  ${SNMP_MGR1_IP}  ${SNMP_DEFAULT_PORT}


Configure SNMP Settings On BMC With Empty Port Via GUI And Verify
    [Documentation]  Configure SNMP settings on BMC with empty port via GUI and verify.
    [Tags]  Configure_SNMP_Settings_On_BMC_With_Empty_Port_Via_GUI_And_Verify
    [Teardown]  Delete SNMP Manager Via GUI  ${SNMP_MGR1_IP}  ${SNMP_DEFAULT_PORT}

    Configure SNMP Manager Via GUI  ${SNMP_MGR1_IP}  ${empty_port}

    Wait Until Page Contains  ${SNMP_MGR1_IP}  timeout=45s

    # SNMP Manager IP is set with default port number when no port number is provided.
    Verify SNMP Manager Configured On BMC  ${SNMP_MGR1_IP}  ${SNMP_DEFAULT_PORT}


Configure Invalid SNMP Settings On BMC Via GUI And Verify

    [Documentation]  Configure invalid SNMP settings on BMC via GUI and verify.
    [Tags]  Configure_Invalid_SNMP_Settings_On_BMC_Via_GUI_And_Verify
    [Template]  Configure SNMP Manager On BMC With Invalid Setting Via GUI And Verify

    # snmp_manager_ip   snmp_manager_port        Expected status
    ${SNMP_MGR1_IP}     ${out_of_range_port}     ${invalid_port_error}
    ${SNMP_MGR1_IP}     ${alpha_port}            ${invalid_port_error}
    ${SNMP_MGR1_IP}     ${negative_port}         ${invalid_port_error}
    ${out_of_range_ip}  ${NON_DEFAULT_PORT1}     ${invalid_destination_error}
    ${alpha_ip}         ${NON_DEFAULT_PORT1}     ${invalid_destination_error}


Configure Multiple SNMP Managers On BMC Via GUI And Verify
    [Documentation]  Configure multiple SNMP managers on BMC via GUI and verify.
    [Tags]  Configure_Multiple_SNMP_Managers_On_BMC_Via_GUI_And_Verify
    [Template]  Configure Multiple SNMP Managers On BMC With Valid Port Via GUI And Verify

    # snmp_manager_ip      snmp_port
    ${SNMP_MGR1_IP}     ${SNMP_DEFAULT_PORT}
    ${SNMP_MGR2_IP}     ${SNMP_DEFAULT_PORT}


Configure Multiple SNMP Managers With Non Default Port Via GUI And Verify
    [Documentation]  Configure multiple SNMP managers with non-default port via GUI and verify.
    [Tags]  Configure_Multiple_SNMP_Managers_With_Non_Default_Port_Via_GUI_And_Verify
    [Template]  Configure Multiple SNMP Managers On BMC With Valid Port Via GUI And Verify

    # snmp_manager_ip      snmp_port
    ${SNMP_MGR1_IP}     ${NON_DEFAULT_PORT1}
    ${SNMP_MGR2_IP}     ${NON_DEFAULT_PORT1}


Configure Multiple SNMP Managers With Different Ports Via GUI And Verify
    [Documentation]  Configure multiple SNMP managers with different ports via GUI and verify.
    [Tags]  Configure_Multiple_SNMP_Managers_With_Different_Ports_Via_GUI_And_Verify
    [Template]  Configure Multiple SNMP Managers On BMC With Valid Port Via GUI And Verify

    # snmp_manager_ip      snmp_port
    ${SNMP_MGR1_IP}     ${NON_DEFAULT_PORT1}
    ${SNMP_MGR2_IP}     ${SNMP_DEFAULT_PORT}
    ${SNMP_MGR3_IP}     ${NON_DEFAULT_PORT2}


Configure Multiple SNMP Managers On BMC Via GUI And Verify Persistency On BMC Reboot
    [Documentation]  Login GUI SNMP alerts page and
    ...  add multiple SNMP Managers on BMC via GUI and verify persistency on BMC reboot.
    [Tags]  Configure_Multiple_SNMP_Managers_On_BMC_Via_GUI_And_Verify_Persistency_On_BMC_Reboot
    [Teardown]   Run Keywords  Delete SNMP Manager Via GUI  ${SNMP_MGR1_IP}  ${SNMP_DEFAULT_PORT}
    ...  AND  Delete SNMP Manager Via GUI  ${SNMP_MGR2_IP}  ${SNMP_DEFAULT_PORT}

    Configure SNMP Manager Via GUI  ${SNMP_MGR1_IP}  ${SNMP_DEFAULT_PORT}
    Wait Until Page Contains  ${SNMP_MGR1_IP}  timeout=45s

    Configure SNMP Manager Via GUI  ${SNMP_MGR2_IP}  ${SNMP_DEFAULT_PORT}
    Wait Until Page Contains  ${SNMP_MGR2_IP}  timeout=45s

    # Reboot BMC and check persistency SNMP manager.
    Reboot BMC via GUI

    Suite Setup Execution
    Wait Until Page Contains  ${snmp_page_heading}  timeout=1min

    Verify SNMP Manager Configured On BMC  ${SNMP_MGR1_IP}  ${SNMP_DEFAULT_PORT}
    Verify SNMP Manager Configured On BMC  ${SNMP_MGR2_IP}  ${SNMP_DEFAULT_PORT}


Configure SNMP Manager Via GUI And Verify SNMP Trap
    [Documentation]  Login GUI SNMP alerts page and add SNMP manager via GUI
    ...  and generate error on BMC and verify trap and its fields.
    [Tags]  Configure_SNMP_Manager_Via_GUI_And_Verify_SNMP_Trap
    [Template]  Create Error On BMC And Verify Trap On Default Port
    [Teardown]  Delete SNMP Manager Via GUI  ${SNMP_MGR1_IP}  ${SNMP_DEFAULT_PORT}

    # event_log                 expected_error

    # Generate internal failure error.
    ${CMD_INTERNAL_FAILURE}     ${SNMP_TRAP_BMC_INTERNAL_FAILURE}

    # Generate timeout error.
    ${CMD_FRU_CALLOUT}          ${SNMP_TRAP_BMC_CALLOUT_ERROR}

    # Generate informational error.
    ${CMD_INFORMATIONAL_ERROR}  ${SNMP_TRAP_BMC_INFORMATIONAL_ERROR}


*** Keywords ***

Suite Setup Execution
    [Documentation]  Do test case setup tasks.

    Launch Browser And Login GUI

    Click Element  ${xpath_settings_menu}
    Click Element  ${xpath_snmp_alerts_sub_menu}
    Wait Until Keyword Succeeds  30 sec  10 sec  Location Should Contain  snmp-alerts


Configure SNMP Manager Via GUI
    [Documentation]  Configure SNMP manager via GUI.
    [Arguments]  ${snmp_ip}  ${port}

    # Description of argument(s):
    # snmp_ip  SNMP manager IP address.
    # port     SNMP manager port.

    Click Element  ${xpath_add_destination}
    Wait Until Page Contains Element  ${xpath_snmp_alert_destination_heading}
    Input Text  ${xpath_ip_address_input_button}  ${snmp_ip}
    Wait Until Keyword Succeeds  30 sec  5 sec  Get Value  ${xpath_ip_address_input_button}
    Input Text  ${xpath_port_optional_input_button}  ${port}
    Click Element  ${xpath_snmp_add_destination_button}


Delete SNMP Manager Via GUI
    [Documentation]  Delete SNMP manager via GUI.
    [Arguments]  ${snmp_mgr_ip}  ${snmp_mgr_port}

    # Description of argument(s):
    # snmp_mgr_ip       SNMP manager IP address.
    # snmp_mgr_port     SNMP manager port.

    Wait Until Page Contains  ${snmp_mgr_ip}  ${snmp_mgr_port}
    Click Element At Coordinates  ${xpath_select_all_snmp}  0  0
    Wait Until Keyword Succeeds  30 sec  5 sec  Click Element  ${xpath_delete_button}
    Wait Until Page Contains  Delete SNMP alert destination
    Click Element  ${xpath_delete_destination}
    Wait Until Page Contains  Successfully deleted SNMP alert destination  timeout=45s
    Wait Until Keyword Succeeds  30 sec  10 sec  Refresh GUI And Verify Element Value
    ...  ${xpath_snmp_alerts_heading}  ${snmp_page_heading}


Configure SNMP Manager On BMC With Invalid Setting Via GUI And Verify

    [Documentation]  Configure SNMP manager on BMC with invalid setting via GUI and verify.
    [Arguments]  ${snmp_manager_ip}  ${snmp_manager_port}  ${expected_error}
    [Teardown]  Run Keyword If  '${expected_error}' == '${invalid_port_error}'
    ...  Click Element  ${xpath_cancel_button}

    # Description of argument(s):
    # snmp_manager_ip     SNMP manager IP address.
    # snmp_manager_port   SNMP manager port.
    # expected_error      Expected error optionally provided in testcase
    # ....                (e.g. Invalid format / Value must be between 0 – 65535).

    Configure SNMP Manager Via GUI  ${snmp_manager_ip}  ${snmp_manager_port}
    Wait Until Page Contains   ${expected_error}
    ${status}=  Run Keyword And Return Status
    ...  Verify SNMP Manager Configured On BMC  ${snmp_manager_ip}  ${snmp_manager_port}
    Should Be Equal As Strings  ${status}  False
    ...  msg=BMC is allowing to configure with invalid SNMP settings.


Configure Multiple SNMP Managers On BMC With Valid Port Via GUI And Verify
    [Documentation]  Configure multiple SNMP managers on BMC with valid port value via GUI and verify.
    [Arguments]  ${snmp_ip_value}  ${snmp_port_value}
    [Teardown]  Delete SNMP Manager Via GUI  ${snmp_ip_value}  ${snmp_port_value}

    # Description of argument(s):
    # snmp_ip_value     SNMP manager IP address.
    # snmp_port_value   SNMP manager port.

    Configure SNMP Manager Via GUI  ${snmp_ip_value}  ${snmp_port_value}
    Verify SNMP Manager Configured On BMC  ${snmp_ip_value}  ${snmp_port_value}


Create Error On BMC And Verify Trap On Default Port
    [Documentation]  Generate error on BMC and verify if trap is sent to default port.
    [Arguments]  ${event_log}=${CMD_INTERNAL_FAILURE}  ${expected_error}=${SNMP_TRAP_BMC_INTERNAL_FAILURE}

    # Description of argument(s):
    # event_log       Event logs to be created.
    # expected_error  Expected error on SNMP.

    Configure SNMP Manager Via GUI  ${SNMP_MGR1_IP}  ${SNMP_DEFAULT_PORT}

    Start SNMP Manager

    # Generate error log.
    BMC Execute Command  ${event_log}

    SSHLibrary.Switch Connection  snmp_server
    ${SNMP_LISTEN_OUT}=  Read  delay=1s

    # Stop SNMP manager process.
    SSHLibrary.Execute Command  sudo killall snmptrapd

    # Sample SNMP trap:
    # 2021-06-16 07:05:29 xx.xx.xx.xx [UDP: [xx.xx.xx.xx]:58154->[xx.xx.xx.xx]:xxx]:
    # DISMAN-EVENT-MIB::sysUpTimeInstance = Timeticks: (2100473) 5:50:04.73
    #   SNMPv2-MIB::snmpTrapOID.0 = OID: SNMPv2-SMI::enterprises.49871.1.0.0.1
    #  SNMPv2-SMI::enterprises.49871.1.0.1.1 = Gauge32: 369    SNMPv2-SMI::enterprises.49871.1.0.1.2 = Opaque:
    # UInt64: 1397718405502468474     SNMPv2-SMI::enterprises.49871.1.0.1.3 = INTEGER: 3
    #      SNMPv2-SMI::enterprises.49871.1.0.1.4 = STRING: "xxx.xx.xx Failure"

    ${lines}=  Split To Lines  ${SNMP_LISTEN_OUT}
    ${trap_info}=  Get From List  ${lines}  -1
    ${snmp_trap}=  Split String  ${trap_info}  \t

    Verify SNMP Trap  ${snmp_trap}  ${expected_error}
