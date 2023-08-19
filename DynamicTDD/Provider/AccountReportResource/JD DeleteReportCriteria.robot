*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Appointment Report
Library           Collections
Library           String
Library           json
Library           DateTime
Library           requests
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/musers.py
Variables         /ebs/TDD/varfiles/consumermail.py
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py


       
*** Variables ***
${SERVICE1}   SERVICE1
${SERVICE2}   SERVICE2
${SERVICE3}   SERVICE3
${SERVICE4}   SERVICE4
${parallel}     1
${digits}       0123456789
${self}         0
@{jid}          1  2  3  4  5
@{service_duration}   5   20
${ZOOM_url}    https://zoom.us/j/{}?pwd=THVLcTBZa2lESFZQbU9DQTQrWUxWZz09
@{EMPTY_List}
@{reportNames}     report112   report112#14  Report234@!  report!2  123reort  124Report  @1!Report



*** Test Cases ***

JD-TC-Save_Report_Criteria-1
    [Documentation]  Save report and delete report 
    ${resp}=  Encrypted Provider Login  ${PUSERNAME13}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${pid}=  get_acc_id  ${PUSERNAME13}
    Set Suite Variable  ${pid}

    ${duration}=   Random Int  min=2  max=10
    Set Suite Variable   ${duration}
    
    ${resp}=  Update Waitlist Settings  ${calc_mode[1]}   ${duration}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${bool[1]}  ${Empty}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${resp}=  View Waitlist Settings
    Log   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  calculationMode=${calc_mode[1]}  trnArndTime=${duration}  futureDateWaitlist=${bool[1]}  showTokenId=${bool[1]}  onlineCheckIns=${bool[1]}  maxPartySize=1
    
    clear_queue     ${PUSERNAME13}
    clear_service   ${PUSERNAME13}
    clear_appt_schedule   ${PUSERNAME13}

    Set Test Variable  ${reportType}              APPOINTMENT
    Set Test Variable  ${reportDateCategory}      TODAY
    ${filter2}=  Create Dictionary   apptForId-eq=${jid[0]},${jid[3]},${jid[1]} 
    ${resp}=  Save Report Criteria  ${reportNames[0]}  ${reportType}  ${reportDateCategory}  ${filter2}
    # Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Report Criteria   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Should Be Equal As Strings   ${resp.json()[0]['reportCriteria']['apptForId-eq']}     ${jid[0]},${jid[3]},${jid[1]}
    Should Be Equal As Strings   ${resp.json()[0]['reportName']}             ${reportNames[0]}
    Should Be Equal As Strings   ${resp.json()[0]['reportType']}             ${reportType}
    Should Be Equal As Strings   ${resp.json()[0]['reportDateCategory']}     ${reportDateCategory}

    ${resp}=  Delete Report Criteria  ${reportNames[0]}  ${reportType}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 

    ${resp}=  Get Report Criteria   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings   ${resp.json()}   ${EMPTY_List} 


JD-TC-Save_Report_Criteria-UH1
    [Documentation]   Delete Report Without login
    
    Set Test Variable  ${reportType}     APPOINTMENT 
    ${resp}=  Delete Report Criteria  ${reportNames[0]}  ${reportType}
    # Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"


JD-TC-Save_Report_Criteria-UH2
    [Documentation]   Login as consumer and try to Delete Report
    ${resp}=   Consumer Login  ${CUSERNAME16}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Set Test Variable  ${reportType}     APPOINTMENT 
    ${resp}=  Delete Report Criteria  ${reportNames[0]}  ${reportType}
    # Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}" 


JD-TC-Save_Report_Criteria-UH3
    [Documentation]   A provider try to Delete Report without saving any report
    ${resp}=  Encrypted Provider Login  ${PUSERNAME200}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Set Test Variable  ${reportType}      APPOINTMENT 
    ${resp}=  Delete Report Criteria  ${reportNames[0]}  ${reportType}
    # Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${REPORT_NAME_NOT_EXIST}"

