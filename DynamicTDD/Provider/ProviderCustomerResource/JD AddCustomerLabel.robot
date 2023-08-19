*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        AddCustomer Label
Library           String
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

***Variables***
&{Emptydict}

***Test Cases***

JD-TC-AddCustomerLabel-1
    [Documentation]  Add a label for a customer.
     
    clear_service   ${PUSERNAME213}
    clear_location  ${PUSERNAME213}
    clear_appt_schedule   ${PUSERNAME213}
    clear_customer   ${PUSERNAME213}

    ${resp}=  ProviderLogin  ${PUSERNAME213}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name   
    ${resp}=  AddCustomer  ${CUSERNAME38}   firstName=${firstname}   lastName=${lastname} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME38}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    clear_Label  ${PUSERNAME213}
    FOR  ${i}  IN RANGE   5
        ${Values}=  FakerLibrary.Words  	nb=3
        ${status}=  Run Keyword And Return Status   List Should Not Contain Duplicates   ${Values}
        Exit For Loop If  '${status}'=='True'
    END
    ${ShortValues}=  FakerLibrary.Words  	nb=3
    ${Notifmsg}=  FakerLibrary.Words  	nb=3
    ${ValueSet}=  Create ValueSet For Label  ${Values[0]}  ${ShortValues[0]}  ${Values[1]}  ${ShortValues[1]}  ${Values[2]}  ${ShortValues[2]}
    ${NotificationSet}=  Create NotificationSet For Label  ${Values[0]}  ${Notifmsg[0]}  ${Values[1]}  ${Notifmsg[1]}  ${Values[2]}  ${Notifmsg[2]}
    ${labelname}=  FakerLibrary.Words  nb=2
    ${label_desc}=  FakerLibrary.Sentence
    ${resp}=  Create Label  ${labelname[0]}  ${labelname[1]}  ${label_desc}  ${ValueSet}  ${NotificationSet}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${label_id}  ${resp.json()}

    ${resp}=  Get Label By Id  ${label_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['id']}                           ${label_id}
    Should Be Equal As Strings  ${resp.json()['label']}                        ${labelname[0]}
    Should Be Equal As Strings  ${resp.json()['displayName']}                  ${labelname[1]}
    Should Be Equal As Strings  ${resp.json()['description']}                  ${label_desc}
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['value']}         ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['shortValue']}    ${ShortValues[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['value']}         ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['shortValue']}    ${ShortValues[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['value']}         ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['shortValue']}    ${ShortValues[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['values']}    ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['messages']}  ${Notifmsg[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['values']}    ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['messages']}  ${Notifmsg[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['values']}    ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['messages']}  ${Notifmsg[2]}

    ${len}=  Get Length  ${ValueSet}
    ${i}=   Random Int   min=0   max=${len-1}
    ${label_value}=   Set Variable   ${ValueSet[${i}]['value']}
    ${label_dict}=  Create Label Dictionary  ${labelname[0]}  ${label_value}
    ${resp}=  Add Labels for Customers   ${label_dict}   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${label}=    Create Dictionary  ${labelname[0]}=${label_value}
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME38}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['id']}             ${cid}
    Should Be Equal As Strings  ${resp.json()[0]['label']}          ${label}

JD-TC-AddCustomerLabel-2
    [Documentation]  Add same label for multiple customers.
     
    clear_service   ${PUSERNAME214}
    clear_location  ${PUSERNAME214}
    clear_appt_schedule   ${PUSERNAME214}
    clear_customer   ${PUSERNAME214}

    ${resp}=  ProviderLogin  ${PUSERNAME214}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name   
    ${resp}=  AddCustomer  ${CUSERNAME38}   firstName=${firstname}   lastName=${lastname} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME38}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=  FakerLibrary.last_name   
    ${resp}=  AddCustomer  ${CUSERNAME37}   firstName=${firstname1}   lastName=${lastname1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME37}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    clear_Label  ${PUSERNAME214}
    FOR  ${i}  IN RANGE   5
        ${Values}=  FakerLibrary.Words  	nb=3
        ${status}=  Run Keyword And Return Status   List Should Not Contain Duplicates   ${Values}
        Exit For Loop If  '${status}'=='True'
    END
    ${ShortValues}=  FakerLibrary.Words  	nb=3
    ${Notifmsg}=  FakerLibrary.Words  	nb=3
    ${ValueSet}=  Create ValueSet For Label  ${Values[0]}  ${ShortValues[0]}  ${Values[1]}  ${ShortValues[1]}  ${Values[2]}  ${ShortValues[2]}
    ${NotificationSet}=  Create NotificationSet For Label  ${Values[0]}  ${Notifmsg[0]}  ${Values[1]}  ${Notifmsg[1]}  ${Values[2]}  ${Notifmsg[2]}
    ${labelname}=  FakerLibrary.Words  nb=2
    ${label_desc}=  FakerLibrary.Sentence
    ${resp}=  Create Label  ${labelname[0]}  ${labelname[1]}  ${label_desc}  ${ValueSet}  ${NotificationSet}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${label_id}  ${resp.json()}

    ${resp}=  Get Label By Id  ${label_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['id']}                           ${label_id}
    Should Be Equal As Strings  ${resp.json()['label']}                        ${labelname[0]}
    Should Be Equal As Strings  ${resp.json()['displayName']}                  ${labelname[1]}
    Should Be Equal As Strings  ${resp.json()['description']}                  ${label_desc}
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['value']}         ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['shortValue']}    ${ShortValues[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['value']}         ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['shortValue']}    ${ShortValues[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['value']}         ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['shortValue']}    ${ShortValues[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['values']}    ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['messages']}  ${Notifmsg[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['values']}    ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['messages']}  ${Notifmsg[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['values']}    ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['messages']}  ${Notifmsg[2]}

    ${len}=  Get Length  ${ValueSet}
    ${i}=   Random Int   min=0   max=${len-1}
    ${label_value}=   Set Variable   ${ValueSet[${i}]['value']}
    ${label_dict}=  Create Label Dictionary  ${labelname[0]}  ${label_value}
    ${resp}=  Add Labels for Customers   ${label_dict}   ${cid}   ${cid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${label}=    Create Dictionary  ${labelname[0]}=${label_value}
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME38}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['id']}             ${cid}
    Should Be Equal As Strings  ${resp.json()[0]['label']}          ${label}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME37}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['id']}             ${cid1}
    Should Be Equal As Strings  ${resp.json()[0]['label']}          ${label}

JD-TC-AddCustomerLabel-3
    [Documentation]  Add different label for different customers.
     
    clear_service   ${PUSERNAME215}
    clear_location  ${PUSERNAME215}
    clear_appt_schedule   ${PUSERNAME215}
    clear_customer   ${PUSERNAME215}

    ${resp}=  ProviderLogin  ${PUSERNAME215}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name   
    ${resp}=  AddCustomer  ${CUSERNAME38}   firstName=${firstname}   lastName=${lastname} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME38}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${firstname1}=  FakerLibrary.first_name
    ${lastname1}=  FakerLibrary.last_name   
    ${resp}=  AddCustomer  ${CUSERNAME37}   firstName=${firstname1}   lastName=${lastname1} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid1}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME37}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    clear_Label  ${PUSERNAME215}
    FOR  ${i}  IN RANGE   5
        ${Values}=  FakerLibrary.Words  	nb=3
        ${status}=  Run Keyword And Return Status   List Should Not Contain Duplicates   ${Values}
        Exit For Loop If  '${status}'=='True'
    END
    ${ShortValues}=  FakerLibrary.Words  	nb=3
    ${Notifmsg}=  FakerLibrary.Words  	nb=3
    ${ValueSet}=  Create ValueSet For Label  ${Values[0]}  ${ShortValues[0]}  ${Values[1]}  ${ShortValues[1]}  ${Values[2]}  ${ShortValues[2]}
    ${NotificationSet}=  Create NotificationSet For Label  ${Values[0]}  ${Notifmsg[0]}  ${Values[1]}  ${Notifmsg[1]}  ${Values[2]}  ${Notifmsg[2]}
    ${labelname}=  FakerLibrary.Words  nb=2
    ${label_desc}=  FakerLibrary.Sentence
    ${resp}=  Create Label  ${labelname[0]}  ${labelname[1]}  ${label_desc}  ${ValueSet}  ${NotificationSet}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${label_id}  ${resp.json()}

    ${resp}=  Get Label By Id  ${label_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['id']}                           ${label_id}
    Should Be Equal As Strings  ${resp.json()['label']}                        ${labelname[0]}
    Should Be Equal As Strings  ${resp.json()['displayName']}                  ${labelname[1]}
    Should Be Equal As Strings  ${resp.json()['description']}                  ${label_desc}
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['value']}         ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['shortValue']}    ${ShortValues[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['value']}         ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['shortValue']}    ${ShortValues[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['value']}         ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['shortValue']}    ${ShortValues[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['values']}    ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['messages']}  ${Notifmsg[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['values']}    ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['messages']}  ${Notifmsg[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['values']}    ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['messages']}  ${Notifmsg[2]}

    ${len}=  Get Length  ${ValueSet}
    ${i}=   Random Int   min=0   max=${len-1}
    ${label_value}=   Set Variable   ${ValueSet[${i}]['value']}
    ${label_dict}=  Create Label Dictionary  ${labelname[0]}  ${label_value}
    ${resp}=  Add Labels for Customers   ${label_dict}   ${cid}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${label}=    Create Dictionary  ${labelname[0]}=${label_value}
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME38}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['id']}             ${cid}
    Should Be Equal As Strings  ${resp.json()[0]['label']}          ${label}

    FOR  ${i}  IN RANGE   5
        ${Values}=  FakerLibrary.Words  	nb=3
        ${status}=  Run Keyword And Return Status   List Should Not Contain Duplicates   ${Values}
        Exit For Loop If  '${status}'=='True'
    END
    ${ShortValues}=  FakerLibrary.Words  	nb=3
    ${Notifmsg}=  FakerLibrary.Words  	nb=3
    ${ValueSet}=  Create ValueSet For Label  ${Values[0]}  ${ShortValues[0]}  ${Values[1]}  ${ShortValues[1]}  ${Values[2]}  ${ShortValues[2]}
    ${NotificationSet}=  Create NotificationSet For Label  ${Values[0]}  ${Notifmsg[0]}  ${Values[1]}  ${Notifmsg[1]}  ${Values[2]}  ${Notifmsg[2]}
    ${labelname1}=  FakerLibrary.Words  nb=2
    ${label_desc}=  FakerLibrary.Sentence
    ${resp}=  Create Label  ${labelname1[0]}  ${labelname1[1]}  ${label_desc}  ${ValueSet}  ${NotificationSet}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${label_id1}  ${resp.json()}

    ${resp}=  Get Label By Id  ${label_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['id']}                           ${label_id1}
    Should Be Equal As Strings  ${resp.json()['label']}                        ${labelname1[0]}
    Should Be Equal As Strings  ${resp.json()['displayName']}                  ${labelname1[1]}
    Should Be Equal As Strings  ${resp.json()['description']}                  ${label_desc}
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['value']}         ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['shortValue']}    ${ShortValues[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['value']}         ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['shortValue']}    ${ShortValues[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['value']}         ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['shortValue']}    ${ShortValues[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['values']}    ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['messages']}  ${Notifmsg[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['values']}    ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['messages']}  ${Notifmsg[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['values']}    ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['messages']}  ${Notifmsg[2]}

    ${len}=  Get Length  ${ValueSet}
    ${i}=   Random Int   min=0   max=${len-1}
    ${label_value}=   Set Variable   ${ValueSet[${i}]['value']}
    ${label_dict}=  Create Label Dictionary  ${labelname1[0]}  ${label_value}
    ${resp}=  Add Labels for Customers   ${label_dict}   ${cid1}   
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${label1}=    Create Dictionary  ${labelname1[0]}=${label_value}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME37}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['id']}             ${cid1}
    Should Be Equal As Strings  ${resp.json()[0]['label']}          ${label1}

JD-TC-AddCustomerLabel-4
    [Documentation]  Add same label two times for a customer.
     
    clear_service   ${PUSERNAME216}
    clear_location  ${PUSERNAME216}
    clear_appt_schedule   ${PUSERNAME216}
    clear_customer   ${PUSERNAME216}

    ${resp}=  ProviderLogin  ${PUSERNAME216}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name   
    ${resp}=  AddCustomer  ${CUSERNAME38}   firstName=${firstname}   lastName=${lastname} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME38}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    clear_Label  ${PUSERNAME216}
    FOR  ${i}  IN RANGE   5
        ${Values}=  FakerLibrary.Words  	nb=3
        ${status}=  Run Keyword And Return Status   List Should Not Contain Duplicates   ${Values}
        Exit For Loop If  '${status}'=='True'
    END
    ${ShortValues}=  FakerLibrary.Words  	nb=3
    ${Notifmsg}=  FakerLibrary.Words  	nb=3
    ${ValueSet}=  Create ValueSet For Label  ${Values[0]}  ${ShortValues[0]}  ${Values[1]}  ${ShortValues[1]}  ${Values[2]}  ${ShortValues[2]}
    ${NotificationSet}=  Create NotificationSet For Label  ${Values[0]}  ${Notifmsg[0]}  ${Values[1]}  ${Notifmsg[1]}  ${Values[2]}  ${Notifmsg[2]}
    ${labelname}=  FakerLibrary.Words  nb=2
    ${label_desc}=  FakerLibrary.Sentence
    ${resp}=  Create Label  ${labelname[0]}  ${labelname[1]}  ${label_desc}  ${ValueSet}  ${NotificationSet}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${label_id}  ${resp.json()}

    ${resp}=  Get Label By Id  ${label_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['id']}                           ${label_id}
    Should Be Equal As Strings  ${resp.json()['label']}                        ${labelname[0]}
    Should Be Equal As Strings  ${resp.json()['displayName']}                  ${labelname[1]}
    Should Be Equal As Strings  ${resp.json()['description']}                  ${label_desc}
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['value']}         ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['shortValue']}    ${ShortValues[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['value']}         ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['shortValue']}    ${ShortValues[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['value']}         ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['shortValue']}    ${ShortValues[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['values']}    ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['messages']}  ${Notifmsg[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['values']}    ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['messages']}  ${Notifmsg[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['values']}    ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['messages']}  ${Notifmsg[2]}

    ${len}=  Get Length  ${ValueSet}
    ${i}=   Random Int   min=0   max=${len-1}
    ${label_value}=   Set Variable   ${ValueSet[${i}]['value']}
    ${label_dict}=  Create Label Dictionary  ${labelname[0]}  ${label_value}
    ${resp}=  Add Labels for Customers   ${label_dict}   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${label}=    Create Dictionary  ${labelname[0]}=${label_value}
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME38}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['id']}             ${cid}
    Should Be Equal As Strings  ${resp.json()[0]['label']}          ${label}
    
    ${label_dict}=  Create Label Dictionary  ${labelname[0]}  ${label_value}
    ${resp}=  Add Labels for Customers   ${label_dict}   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${label}=    Create Dictionary  ${labelname[0]}=${label_value}
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME38}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['id']}             ${cid}
    Should Be Equal As Strings  ${resp.json()[0]['label']}          ${label}

JD-TC-AddCustomerLabel-5
    [Documentation]  Add different label two times for a customer.
     
    clear_service   ${PUSERNAME216}
    clear_location  ${PUSERNAME216}
    clear_appt_schedule   ${PUSERNAME216}
    clear_customer   ${PUSERNAME216}

    ${resp}=  ProviderLogin  ${PUSERNAME216}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name   
    ${resp}=  AddCustomer  ${CUSERNAME38}   firstName=${firstname}   lastName=${lastname} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME38}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    clear_Label  ${PUSERNAME216}
    FOR  ${i}  IN RANGE   5
        ${Values}=  FakerLibrary.Words  	nb=3
        ${status}=  Run Keyword And Return Status   List Should Not Contain Duplicates   ${Values}
        Exit For Loop If  '${status}'=='True'
    END
    ${ShortValues}=  FakerLibrary.Words  	nb=3
    ${Notifmsg}=  FakerLibrary.Words  	nb=3
    ${ValueSet}=  Create ValueSet For Label  ${Values[0]}  ${ShortValues[0]}  ${Values[1]}  ${ShortValues[1]}  ${Values[2]}  ${ShortValues[2]}
    ${NotificationSet}=  Create NotificationSet For Label  ${Values[0]}  ${Notifmsg[0]}  ${Values[1]}  ${Notifmsg[1]}  ${Values[2]}  ${Notifmsg[2]}
    ${labelname}=  FakerLibrary.Words  nb=2
    ${label_desc}=  FakerLibrary.Sentence
    ${resp}=  Create Label  ${labelname[0]}  ${labelname[1]}  ${label_desc}  ${ValueSet}  ${NotificationSet}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${label_id}  ${resp.json()}

    ${resp}=  Get Label By Id  ${label_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['id']}                           ${label_id}
    Should Be Equal As Strings  ${resp.json()['label']}                        ${labelname[0]}
    Should Be Equal As Strings  ${resp.json()['displayName']}                  ${labelname[1]}
    Should Be Equal As Strings  ${resp.json()['description']}                  ${label_desc}
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['value']}         ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['shortValue']}    ${ShortValues[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['value']}         ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['shortValue']}    ${ShortValues[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['value']}         ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['shortValue']}    ${ShortValues[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['values']}    ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['messages']}  ${Notifmsg[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['values']}    ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['messages']}  ${Notifmsg[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['values']}    ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['messages']}  ${Notifmsg[2]}

    ${len}=  Get Length  ${ValueSet}
    ${i}=   Random Int   min=0   max=${len-1}
    ${label_value}=   Set Variable   ${ValueSet[${i}]['value']}
    ${label_dict}=  Create Label Dictionary  ${labelname[0]}  ${label_value}
    ${resp}=  Add Labels for Customers   ${label_dict}   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${label}=    Create Dictionary  ${labelname[0]}=${label_value}
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME38}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['id']}             ${cid}
    Should Be Equal As Strings  ${resp.json()[0]['label']}          ${label}

    FOR  ${i}  IN RANGE   5
        ${Values}=  FakerLibrary.Words  	nb=3
        ${status}=  Run Keyword And Return Status   List Should Not Contain Duplicates   ${Values}
        Exit For Loop If  '${status}'=='True'
    END
    ${ShortValues}=  FakerLibrary.Words  	nb=3
    ${Notifmsg}=  FakerLibrary.Words  	nb=3
    ${ValueSet}=  Create ValueSet For Label  ${Values[0]}  ${ShortValues[0]}  ${Values[1]}  ${ShortValues[1]}  ${Values[2]}  ${ShortValues[2]}
    ${NotificationSet}=  Create NotificationSet For Label  ${Values[0]}  ${Notifmsg[0]}  ${Values[1]}  ${Notifmsg[1]}  ${Values[2]}  ${Notifmsg[2]}
    ${labelname1}=  FakerLibrary.Words  nb=2
    ${label_desc}=  FakerLibrary.Sentence
    ${resp}=  Create Label  ${labelname1[0]}  ${labelname1[1]}  ${label_desc}  ${ValueSet}  ${NotificationSet}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${label_id1}  ${resp.json()}

    ${resp}=  Get Label By Id  ${label_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['id']}                           ${label_id1}
    Should Be Equal As Strings  ${resp.json()['label']}                        ${labelname1[0]}
    Should Be Equal As Strings  ${resp.json()['displayName']}                  ${labelname1[1]}
    Should Be Equal As Strings  ${resp.json()['description']}                  ${label_desc}
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['value']}         ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['shortValue']}    ${ShortValues[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['value']}         ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['shortValue']}    ${ShortValues[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['value']}         ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['shortValue']}    ${ShortValues[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['values']}    ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['messages']}  ${Notifmsg[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['values']}    ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['messages']}  ${Notifmsg[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['values']}    ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['messages']}  ${Notifmsg[2]}

    ${len}=  Get Length  ${ValueSet}
    ${i}=   Random Int   min=0   max=${len-1}
    ${label_value1}=   Set Variable   ${ValueSet[${i}]['value']}
    ${label_dict}=  Create Label Dictionary  ${labelname1[0]}  ${label_value1}
    ${resp}=  Add Labels for Customers   ${label_dict}   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${label1}=    Create Dictionary  ${labelname[0]}=${label_value}  ${labelname1[0]}=${label_value1}
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME38}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['id']}             ${cid}
    # Should Be Equal As Strings  ${resp.json()[0]['label']}          ${label1}
    Dictionary Should Contain Key   ${resp.json()[0]['label']}  ${labelname[0]}  
    Dictionary Should Contain Value   ${resp.json()[0]['label']}   ${label_value}
    Dictionary Should Contain Key   ${resp.json()[0]['label']}  ${labelname1[0]}
    Dictionary Should Contain Value   ${resp.json()[0]['label']}   ${label_value1}

JD-TC-AddCustomerLabel-6
    [Documentation]  Give label name as integer for a customer.
     
    clear_service   ${PUSERNAME217}
    clear_location  ${PUSERNAME217}
    clear_appt_schedule   ${PUSERNAME217}
    clear_customer   ${PUSERNAME217}

    ${resp}=  ProviderLogin  ${PUSERNAME217}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name   
    ${resp}=  AddCustomer  ${CUSERNAME38}   firstName=${firstname}   lastName=${lastname} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME38}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    clear_Label  ${PUSERNAME217}
    FOR  ${i}  IN RANGE   5
        ${Values}=  FakerLibrary.Words  	nb=3
        ${status}=  Run Keyword And Return Status   List Should Not Contain Duplicates   ${Values}
        Exit For Loop If  '${status}'=='True'
    END
    ${ShortValues}=  FakerLibrary.Words  	nb=3
    ${Notifmsg}=  FakerLibrary.Words  	nb=3
    ${ValueSet}=  Create ValueSet For Label  ${Values[0]}  ${ShortValues[0]}  ${Values[1]}  ${ShortValues[1]}  ${Values[2]}  ${ShortValues[2]}
    ${NotificationSet}=  Create NotificationSet For Label  ${Values[0]}  ${Notifmsg[0]}  ${Values[1]}  ${Notifmsg[1]}  ${Values[2]}  ${Notifmsg[2]}
    ${labelname}=  FakerLibrary.Words  nb=2
    ${label_desc}=  FakerLibrary.Sentence
    ${resp}=  Create Label  ${labelname[0]}  ${labelname[1]}  ${label_desc}  ${ValueSet}  ${NotificationSet}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${label_id}  ${resp.json()}

    ${resp}=  Get Label By Id  ${label_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['id']}                           ${label_id}
    Should Be Equal As Strings  ${resp.json()['label']}                        ${labelname[0]}
    Should Be Equal As Strings  ${resp.json()['displayName']}                  ${labelname[1]}
    Should Be Equal As Strings  ${resp.json()['description']}                  ${label_desc}
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['value']}         ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['shortValue']}    ${ShortValues[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['value']}         ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['shortValue']}    ${ShortValues[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['value']}         ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['shortValue']}    ${ShortValues[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['values']}    ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['messages']}  ${Notifmsg[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['values']}    ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['messages']}  ${Notifmsg[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['values']}    ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['messages']}  ${Notifmsg[2]}
    
    ${lblname}=  Convert To String  ${labelname[0]}
    ${len}=  Get Length  ${ValueSet}
    ${i}=   Random Int   min=0   max=${len-1}
    ${label_value}=   Set Variable   ${ValueSet[${i}]['value']}
    ${label_dict}=  Create Label Dictionary  ${lblname}  ${label_value}
    ${resp}=  Add Labels for Customers   ${label_dict}   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${label}=    Create Dictionary  ${lblname}=${label_value}
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME38}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['id']}             ${cid}
    Should Be Equal As Strings  ${resp.json()[0]['label']}          ${label}

JD-TC-AddCustomerLabel-7
    [Documentation]  Give label value as integer for a customer.
     
    clear_service   ${PUSERNAME217}
    clear_location  ${PUSERNAME217}
    clear_appt_schedule   ${PUSERNAME217}
    clear_customer   ${PUSERNAME217}

    ${resp}=  ProviderLogin  ${PUSERNAME217}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name   
    ${resp}=  AddCustomer  ${CUSERNAME38}   firstName=${firstname}   lastName=${lastname} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME38}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    clear_Label  ${PUSERNAME217}
    FOR  ${i}  IN RANGE   5
        ${Values}=  FakerLibrary.Words  	nb=3
        ${status}=  Run Keyword And Return Status   List Should Not Contain Duplicates   ${Values}
        Exit For Loop If  '${status}'=='True'
    END
    ${ShortValues}=  FakerLibrary.Words  	nb=3
    ${Notifmsg}=  FakerLibrary.Words  	nb=3
    ${ValueSet}=  Create ValueSet For Label  ${Values[0]}  ${ShortValues[0]}  ${Values[1]}  ${ShortValues[1]}  ${Values[2]}  ${ShortValues[2]}
    ${NotificationSet}=  Create NotificationSet For Label  ${Values[0]}  ${Notifmsg[0]}  ${Values[1]}  ${Notifmsg[1]}  ${Values[2]}  ${Notifmsg[2]}
    ${labelname}=  FakerLibrary.Words  nb=2
    ${label_desc}=  FakerLibrary.Sentence
    ${resp}=  Create Label  ${labelname[0]}  ${labelname[1]}  ${label_desc}  ${ValueSet}  ${NotificationSet}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${label_id}  ${resp.json()}

    ${resp}=  Get Label By Id  ${label_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['id']}                           ${label_id}
    Should Be Equal As Strings  ${resp.json()['label']}                        ${labelname[0]}
    Should Be Equal As Strings  ${resp.json()['displayName']}                  ${labelname[1]}
    Should Be Equal As Strings  ${resp.json()['description']}                  ${label_desc}
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['value']}         ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['shortValue']}    ${ShortValues[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['value']}         ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['shortValue']}    ${ShortValues[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['value']}         ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['shortValue']}    ${ShortValues[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['values']}    ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['messages']}  ${Notifmsg[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['values']}    ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['messages']}  ${Notifmsg[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['values']}    ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['messages']}  ${Notifmsg[2]}
    
    ${len}=  Get Length  ${ValueSet}
    ${i}=   Random Int   min=0   max=${len-1}
    ${label_value}=   Set Variable   ${ValueSet[${i}]['value']}
    ${lblvalue}=  Convert To String  ${label_value}
    ${label_dict}=  Create Label Dictionary  ${labelname[0]}  ${lblvalue}
    ${resp}=  Add Labels for Customers   ${label_dict}   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${label}=    Create Dictionary  ${labelname[0]}=${lblvalue}
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME38}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['id']}             ${cid}
    Should Be Equal As Strings  ${resp.json()[0]['label']}          ${label}

JD-TC-AddCustomerLabel-8
    [Documentation]  Remove customer label and add the same label again.
     
    clear_service   ${PUSERNAME213}
    clear_location  ${PUSERNAME213}
    clear_appt_schedule   ${PUSERNAME213}
    clear_customer   ${PUSERNAME213}

    ${resp}=  ProviderLogin  ${PUSERNAME213}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name   
    ${resp}=  AddCustomer  ${CUSERNAME38}   firstName=${firstname}   lastName=${lastname} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME38}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    clear_Label  ${PUSERNAME213}
    FOR  ${i}  IN RANGE   5
        ${Values}=  FakerLibrary.Words  	nb=3
        ${status}=  Run Keyword And Return Status   List Should Not Contain Duplicates   ${Values}
        Exit For Loop If  '${status}'=='True'
    END
    ${ShortValues}=  FakerLibrary.Words  	nb=3
    ${Notifmsg}=  FakerLibrary.Words  	nb=3
    ${ValueSet}=  Create ValueSet For Label  ${Values[0]}  ${ShortValues[0]}  ${Values[1]}  ${ShortValues[1]}  ${Values[2]}  ${ShortValues[2]}
    ${NotificationSet}=  Create NotificationSet For Label  ${Values[0]}  ${Notifmsg[0]}  ${Values[1]}  ${Notifmsg[1]}  ${Values[2]}  ${Notifmsg[2]}
    ${labelname}=  FakerLibrary.Words  nb=2
    ${label_desc}=  FakerLibrary.Sentence
    ${resp}=  Create Label  ${labelname[0]}  ${labelname[1]}  ${label_desc}  ${ValueSet}  ${NotificationSet}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${label_id}  ${resp.json()}

    ${resp}=  Get Label By Id  ${label_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['id']}                           ${label_id}
    Should Be Equal As Strings  ${resp.json()['label']}                        ${labelname[0]}
    Should Be Equal As Strings  ${resp.json()['displayName']}                  ${labelname[1]}
    Should Be Equal As Strings  ${resp.json()['description']}                  ${label_desc}
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['value']}         ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['shortValue']}    ${ShortValues[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['value']}         ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['shortValue']}    ${ShortValues[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['value']}         ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['shortValue']}    ${ShortValues[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['values']}    ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['messages']}  ${Notifmsg[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['values']}    ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['messages']}  ${Notifmsg[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['values']}    ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['messages']}  ${Notifmsg[2]}

    ${len}=  Get Length  ${ValueSet}
    ${i}=   Random Int   min=0   max=${len-1}
    ${label_value}=   Set Variable   ${ValueSet[${i}]['value']}
    ${label_dict}=  Create Label Dictionary  ${labelname[0]}  ${label_value}
    ${resp}=  Add Labels for Customers   ${label_dict}   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${label}=    Create Dictionary  ${labelname[0]}=${label_value}
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME38}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['id']}             ${cid}
    Should Be Equal As Strings  ${resp.json()[0]['label']}          ${label}

    ${resp}=  Remove Customer Label   ${cid}  ${labelname[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME38}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['id']}             ${cid}
    Should Be Equal As Strings  ${resp.json()[0]['label']}          ${Emptydict}

    ${label_dict}=  Create Label Dictionary  ${labelname[0]}  ${label_value}
    ${resp}=  Add Labels for Customers   ${label_dict}   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME38}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[0]['id']}             ${cid}
    Should Be Equal As Strings  ${resp.json()[0]['label']}          ${label}

JD-TC-AddCustomerLabel-9
    [Documentation]  Add a label for a familymember with consumers label as empty.
     
    clear_service   ${PUSERNAME213}
    clear_location  ${PUSERNAME213}
    clear_appt_schedule   ${PUSERNAME213}
    clear_customer   ${PUSERNAME213}

    ${resp}=  ProviderLogin  ${PUSERNAME213}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name   
    ${resp}=  AddCustomer  ${CUSERNAME38}   firstName=${firstname}   lastName=${lastname} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME38}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${firstname0}=  FakerLibrary.first_name
    ${lastname0}=  FakerLibrary.last_name
    ${dob0}=  FakerLibrary.Date
    ${gender0}=  Random Element    ${Genderlist}
    ${resp}=  AddFamilyMemberByProvider  ${cid}  ${firstname0}  ${lastname0}  ${dob0}  ${gender0}  
    Log  ${resp.json()}
    Set Test Variable  ${mem_id0}  ${resp.json()}

    clear_Label  ${PUSERNAME213}
    FOR  ${i}  IN RANGE   5
        ${Values}=  FakerLibrary.Words  	nb=3
        ${status}=  Run Keyword And Return Status   List Should Not Contain Duplicates   ${Values}
        Exit For Loop If  '${status}'=='True'
    END
    ${ShortValues}=  FakerLibrary.Words  	nb=3
    ${Notifmsg}=  FakerLibrary.Words  	nb=3
    ${ValueSet}=  Create ValueSet For Label  ${Values[0]}  ${ShortValues[0]}  ${Values[1]}  ${ShortValues[1]}  ${Values[2]}  ${ShortValues[2]}
    ${NotificationSet}=  Create NotificationSet For Label  ${Values[0]}  ${Notifmsg[0]}  ${Values[1]}  ${Notifmsg[1]}  ${Values[2]}  ${Notifmsg[2]}
    ${labelname}=  FakerLibrary.Words  nb=2
    ${label_desc}=  FakerLibrary.Sentence
    ${resp}=  Create Label  ${labelname[0]}  ${labelname[1]}  ${label_desc}  ${ValueSet}  ${NotificationSet}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${label_id}  ${resp.json()}

    ${resp}=  Get Label By Id  ${label_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['id']}                           ${label_id}
    Should Be Equal As Strings  ${resp.json()['label']}                        ${labelname[0]}
    Should Be Equal As Strings  ${resp.json()['displayName']}                  ${labelname[1]}
    Should Be Equal As Strings  ${resp.json()['description']}                  ${label_desc}
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['value']}         ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['shortValue']}    ${ShortValues[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['value']}         ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['shortValue']}    ${ShortValues[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['value']}         ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['shortValue']}    ${ShortValues[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['values']}    ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['messages']}  ${Notifmsg[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['values']}    ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['messages']}  ${Notifmsg[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['values']}    ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['messages']}  ${Notifmsg[2]}

    ${len}=  Get Length  ${ValueSet}
    ${i}=   Random Int   min=0   max=${len-1}
    ${label_value}=   Set Variable   ${ValueSet[${i}]['value']}
    ${label_dict}=  Create Label Dictionary  ${labelname[0]}  ${label_value}
    ${resp}=  Add Labels for Customers   ${label_dict}   ${mem_id0}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${label}=    Create Dictionary  ${labelname[0]}=${label_value}
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME38}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[1]['id']}             ${cid}
    Should Be Equal As Strings  ${resp.json()[1]['label']}          ${Emptydict}
    Should Be Equal As Strings  ${resp.json()[0]['id']}             ${mem_id0}
    Should Be Equal As Strings  ${resp.json()[0]['label']}          ${label}

JD-TC-AddCustomerLabel-10
    [Documentation]  Add same label for familymember and customer.
     
    clear_service   ${PUSERNAME213}
    clear_location  ${PUSERNAME213}
    clear_appt_schedule   ${PUSERNAME213}
    clear_customer   ${PUSERNAME213}

    ${resp}=  ProviderLogin  ${PUSERNAME213}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name   
    ${resp}=  AddCustomer  ${CUSERNAME38}   firstName=${firstname}   lastName=${lastname} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME38}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${firstname0}=  FakerLibrary.first_name
    ${lastname0}=  FakerLibrary.last_name
    ${dob0}=  FakerLibrary.Date
    ${gender0}=  Random Element    ${Genderlist}
    ${resp}=  AddFamilyMemberByProvider  ${cid}  ${firstname0}  ${lastname0}  ${dob0}  ${gender0}  
    Log  ${resp.json()}
    Set Test Variable  ${mem_id0}  ${resp.json()}

    clear_Label  ${PUSERNAME213}
    FOR  ${i}  IN RANGE   5
        ${Values}=  FakerLibrary.Words  	nb=3
        ${status}=  Run Keyword And Return Status   List Should Not Contain Duplicates   ${Values}
        Exit For Loop If  '${status}'=='True'
    END
    ${ShortValues}=  FakerLibrary.Words  	nb=3
    ${Notifmsg}=  FakerLibrary.Words  	nb=3
    ${ValueSet}=  Create ValueSet For Label  ${Values[0]}  ${ShortValues[0]}  ${Values[1]}  ${ShortValues[1]}  ${Values[2]}  ${ShortValues[2]}
    ${NotificationSet}=  Create NotificationSet For Label  ${Values[0]}  ${Notifmsg[0]}  ${Values[1]}  ${Notifmsg[1]}  ${Values[2]}  ${Notifmsg[2]}
    ${labelname}=  FakerLibrary.Words  nb=2
    ${label_desc}=  FakerLibrary.Sentence
    ${resp}=  Create Label  ${labelname[0]}  ${labelname[1]}  ${label_desc}  ${ValueSet}  ${NotificationSet}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${label_id}  ${resp.json()}

    ${resp}=  Get Label By Id  ${label_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['id']}                           ${label_id}
    Should Be Equal As Strings  ${resp.json()['label']}                        ${labelname[0]}
    Should Be Equal As Strings  ${resp.json()['displayName']}                  ${labelname[1]}
    Should Be Equal As Strings  ${resp.json()['description']}                  ${label_desc}
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['value']}         ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['shortValue']}    ${ShortValues[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['value']}         ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['shortValue']}    ${ShortValues[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['value']}         ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['shortValue']}    ${ShortValues[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['values']}    ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['messages']}  ${Notifmsg[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['values']}    ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['messages']}  ${Notifmsg[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['values']}    ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['messages']}  ${Notifmsg[2]}

    ${len}=  Get Length  ${ValueSet}
    ${i}=   Random Int   min=0   max=${len-1}
    ${label_value}=   Set Variable   ${ValueSet[${i}]['value']}

    ${label_dict}=  Create Label Dictionary  ${labelname[0]}  ${label_value}
    ${resp}=  Add Labels for Customers   ${label_dict}   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${label_dict}=  Create Label Dictionary  ${labelname[0]}  ${label_value}
    ${resp}=  Add Labels for Customers   ${label_dict}   ${mem_id0}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${label}=    Create Dictionary  ${labelname[0]}=${label_value}
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME38}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()[1]['id']}             ${cid}
    Should Be Equal As Strings  ${resp.json()[1]['label']}          ${label}
    Should Be Equal As Strings  ${resp.json()[0]['id']}             ${mem_id0}
    Should Be Equal As Strings  ${resp.json()[0]['label']}          ${label}

JD-TC-AddCustomerLabel-UH1
    [Documentation]  Add a label for a customer without creating label.
     
    clear_service   ${PUSERNAME213}
    clear_location  ${PUSERNAME213}
    clear_appt_schedule   ${PUSERNAME213}
    clear_customer   ${PUSERNAME213}

    ${resp}=  ProviderLogin  ${PUSERNAME213}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name   
    ${resp}=  AddCustomer  ${CUSERNAME38}   firstName=${firstname}   lastName=${lastname} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME38}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${labelname}=   FakerLibrary.word
    ${label_value}=   FakerLibrary.word
    ${label_dict}=  Create Label Dictionary  ${labelname}  ${label_value}
    ${resp}=  Add Labels for Customers   ${label_dict}   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${LABEL_NOT_EXIST}"

JD-TC-AddCustomerLabel-UH2
    [Documentation]  add label with non existant label name.
     
    clear_service   ${PUSERNAME213}
    clear_location  ${PUSERNAME213}
    clear_appt_schedule   ${PUSERNAME213}
    clear_customer   ${PUSERNAME213}

    ${resp}=  ProviderLogin  ${PUSERNAME213}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name   
    ${resp}=  AddCustomer  ${CUSERNAME38}   firstName=${firstname}   lastName=${lastname} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME38}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    clear_Label  ${PUSERNAME213}
    FOR  ${i}  IN RANGE   5
        ${Values}=  FakerLibrary.Words  	nb=3
        ${status}=  Run Keyword And Return Status   List Should Not Contain Duplicates   ${Values}
        Exit For Loop If  '${status}'=='True'
    END
    ${ShortValues}=  FakerLibrary.Words  	nb=3
    ${Notifmsg}=  FakerLibrary.Words  	nb=3
    ${ValueSet}=  Create ValueSet For Label  ${Values[0]}  ${ShortValues[0]}  ${Values[1]}  ${ShortValues[1]}  ${Values[2]}  ${ShortValues[2]}
    ${NotificationSet}=  Create NotificationSet For Label  ${Values[0]}  ${Notifmsg[0]}  ${Values[1]}  ${Notifmsg[1]}  ${Values[2]}  ${Notifmsg[2]}
    ${labelname}=  FakerLibrary.Words  nb=2
    ${label_desc}=  FakerLibrary.Sentence
    ${resp}=  Create Label  ${labelname[0]}  ${labelname[1]}  ${label_desc}  ${ValueSet}  ${NotificationSet}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${label_id}  ${resp.json()}

    ${resp}=  Get Label By Id  ${label_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['id']}                           ${label_id}
    Should Be Equal As Strings  ${resp.json()['label']}                        ${labelname[0]}
    Should Be Equal As Strings  ${resp.json()['displayName']}                  ${labelname[1]}
    Should Be Equal As Strings  ${resp.json()['description']}                  ${label_desc}
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['value']}         ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['shortValue']}    ${ShortValues[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['value']}         ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['shortValue']}    ${ShortValues[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['value']}         ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['shortValue']}    ${ShortValues[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['values']}    ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['messages']}  ${Notifmsg[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['values']}    ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['messages']}  ${Notifmsg[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['values']}    ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['messages']}  ${Notifmsg[2]}
    
    ${lblname}=   FakerLibrary.word
    ${len}=  Get Length  ${ValueSet}
    ${i}=   Random Int   min=0   max=${len-1}
    ${label_value}=   Set Variable   ${ValueSet[${i}]['value']}
    ${label_dict}=  Create Label Dictionary  ${lblname}  ${label_value}
    ${resp}=  Add Labels for Customers   ${label_dict}   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${LABEL_NOT_EXIST}"

JD-TC-AddCustomerLabel-UH3
    [Documentation]  add label with non existant label value.
     
    clear_service   ${PUSERNAME213}
    clear_location  ${PUSERNAME213}
    clear_appt_schedule   ${PUSERNAME213}
    clear_customer   ${PUSERNAME213}

    ${resp}=  ProviderLogin  ${PUSERNAME213}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name   
    ${resp}=  AddCustomer  ${CUSERNAME38}   firstName=${firstname}   lastName=${lastname} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME38}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    clear_Label  ${PUSERNAME213}
    FOR  ${i}  IN RANGE   5
        ${Values}=  FakerLibrary.Words  	nb=3
        ${status}=  Run Keyword And Return Status   List Should Not Contain Duplicates   ${Values}
        Exit For Loop If  '${status}'=='True'
    END
    ${ShortValues}=  FakerLibrary.Words  	nb=3
    ${Notifmsg}=  FakerLibrary.Words  	nb=3
    ${ValueSet}=  Create ValueSet For Label  ${Values[0]}  ${ShortValues[0]}  ${Values[1]}  ${ShortValues[1]}  ${Values[2]}  ${ShortValues[2]}
    ${NotificationSet}=  Create NotificationSet For Label  ${Values[0]}  ${Notifmsg[0]}  ${Values[1]}  ${Notifmsg[1]}  ${Values[2]}  ${Notifmsg[2]}
    ${labelname}=  FakerLibrary.Words  nb=2
    ${label_desc}=  FakerLibrary.Sentence
    ${resp}=  Create Label  ${labelname[0]}  ${labelname[1]}  ${label_desc}  ${ValueSet}  ${NotificationSet}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${label_id}  ${resp.json()}

    ${resp}=  Get Label By Id  ${label_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['id']}                           ${label_id}
    Should Be Equal As Strings  ${resp.json()['label']}                        ${labelname[0]}
    Should Be Equal As Strings  ${resp.json()['displayName']}                  ${labelname[1]}
    Should Be Equal As Strings  ${resp.json()['description']}                  ${label_desc}
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['value']}         ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['shortValue']}    ${ShortValues[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['value']}         ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['shortValue']}    ${ShortValues[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['value']}         ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['shortValue']}    ${ShortValues[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['values']}    ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['messages']}  ${Notifmsg[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['values']}    ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['messages']}  ${Notifmsg[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['values']}    ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['messages']}  ${Notifmsg[2]}
    
    ${lblvalue}=   FakerLibrary.word
    ${label_dict}=  Create Label Dictionary  ${labelname[0]}  ${lblvalue}
    ${resp}=  Add Labels for Customers   ${label_dict}   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${LABEL_VALUE_NOT_EXIST}"

JD-TC-AddCustomerLabel-UH4
    [Documentation]  Add a label for another provider's customer.
     
    clear_service   ${PUSERNAME213}
    clear_location  ${PUSERNAME213}
    clear_appt_schedule   ${PUSERNAME213}
    clear_customer   ${PUSERNAME213}

    ${resp}=  ProviderLogin  ${PUSERNAME212}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_customer   ${PUSERNAME212}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name   
    ${resp}=  AddCustomer  ${CUSERNAME38}   firstName=${firstname}   lastName=${lastname} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME38}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${resp}=  ProviderLogin  ${PUSERNAME213}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_Label  ${PUSERNAME213}
    FOR  ${i}  IN RANGE   5
        ${Values}=  FakerLibrary.Words  	nb=3
        ${status}=  Run Keyword And Return Status   List Should Not Contain Duplicates   ${Values}
        Exit For Loop If  '${status}'=='True'
    END
    ${ShortValues}=  FakerLibrary.Words  	nb=3
    ${Notifmsg}=  FakerLibrary.Words  	nb=3
    ${ValueSet}=  Create ValueSet For Label  ${Values[0]}  ${ShortValues[0]}  ${Values[1]}  ${ShortValues[1]}  ${Values[2]}  ${ShortValues[2]}
    ${NotificationSet}=  Create NotificationSet For Label  ${Values[0]}  ${Notifmsg[0]}  ${Values[1]}  ${Notifmsg[1]}  ${Values[2]}  ${Notifmsg[2]}
    ${labelname}=  FakerLibrary.Words  nb=2
    ${label_desc}=  FakerLibrary.Sentence
    ${resp}=  Create Label  ${labelname[0]}  ${labelname[1]}  ${label_desc}  ${ValueSet}  ${NotificationSet}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${label_id}  ${resp.json()}

    ${resp}=  Get Label By Id  ${label_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['id']}                           ${label_id}
    Should Be Equal As Strings  ${resp.json()['label']}                        ${labelname[0]}
    Should Be Equal As Strings  ${resp.json()['displayName']}                  ${labelname[1]}
    Should Be Equal As Strings  ${resp.json()['description']}                  ${label_desc}
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['value']}         ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['shortValue']}    ${ShortValues[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['value']}         ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['shortValue']}    ${ShortValues[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['value']}         ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['shortValue']}    ${ShortValues[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['values']}    ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['messages']}  ${Notifmsg[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['values']}    ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['messages']}  ${Notifmsg[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['values']}    ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['messages']}  ${Notifmsg[2]}

    ${len}=  Get Length  ${ValueSet}
    ${i}=   Random Int   min=0   max=${len-1}
    ${label_value}=   Set Variable   ${ValueSet[${i}]['value']}
    ${label_dict}=  Create Label Dictionary  ${labelname[0]}  ${label_value}
    ${resp}=  Add Labels for Customers   ${label_dict}   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"   "${NO_PERMISSION}"

JD-TC-AddCustomerLabel-UH5
    [Documentation]  Add another provider's label for a customer.
     
    clear_service   ${PUSERNAME213}
    clear_location  ${PUSERNAME213}
    clear_appt_schedule   ${PUSERNAME213}
    clear_customer   ${PUSERNAME213}

    ${resp}=  ProviderLogin  ${PUSERNAME213}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_Label  ${PUSERNAME213}
    FOR  ${i}  IN RANGE   5
        ${Values}=  FakerLibrary.Words  	nb=3
        ${status}=  Run Keyword And Return Status   List Should Not Contain Duplicates   ${Values}
        Exit For Loop If  '${status}'=='True'
    END
    ${ShortValues}=  FakerLibrary.Words  	nb=3
    ${Notifmsg}=  FakerLibrary.Words  	nb=3
    ${ValueSet}=  Create ValueSet For Label  ${Values[0]}  ${ShortValues[0]}  ${Values[1]}  ${ShortValues[1]}  ${Values[2]}  ${ShortValues[2]}
    ${NotificationSet}=  Create NotificationSet For Label  ${Values[0]}  ${Notifmsg[0]}  ${Values[1]}  ${Notifmsg[1]}  ${Values[2]}  ${Notifmsg[2]}
    ${labelname}=  FakerLibrary.Words  nb=2
    ${label_desc}=  FakerLibrary.Sentence
    ${resp}=  Create Label  ${labelname[0]}  ${labelname[1]}  ${label_desc}  ${ValueSet}  ${NotificationSet}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${label_id}  ${resp.json()}

    ${resp}=  Get Label By Id  ${label_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['id']}                           ${label_id}
    Should Be Equal As Strings  ${resp.json()['label']}                        ${labelname[0]}
    Should Be Equal As Strings  ${resp.json()['displayName']}                  ${labelname[1]}
    Should Be Equal As Strings  ${resp.json()['description']}                  ${label_desc}
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['value']}         ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['shortValue']}    ${ShortValues[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['value']}         ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['shortValue']}    ${ShortValues[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['value']}         ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['shortValue']}    ${ShortValues[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['values']}    ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['messages']}  ${Notifmsg[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['values']}    ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['messages']}  ${Notifmsg[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['values']}    ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['messages']}  ${Notifmsg[2]}

    ${len}=  Get Length  ${ValueSet}
    ${i}=   Random Int   min=0   max=${len-1}
    ${label_value}=   Set Variable   ${ValueSet[${i}]['value']}

    ${resp}=  ProviderLogin  ${PUSERNAME212}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_customer   ${PUSERNAME212}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name   
    ${resp}=  AddCustomer  ${CUSERNAME38}   firstName=${firstname}   lastName=${lastname} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME38}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    ${label_dict}=  Create Label Dictionary  ${labelname[0]}  ${label_value}
    ${resp}=  Add Labels for Customers   ${label_dict}   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${LABEL_NOT_EXIST}"

JD-TC-AddCustomerLabel-UH6
    [Documentation]  Add a label for a customer without login.
     
    clear_service   ${PUSERNAME213}
    clear_location  ${PUSERNAME213}
    clear_appt_schedule   ${PUSERNAME213}
    clear_customer   ${PUSERNAME213}

    ${resp}=  ProviderLogin  ${PUSERNAME213}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name   
    ${resp}=  AddCustomer  ${CUSERNAME38}   firstName=${firstname}   lastName=${lastname} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME38}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    clear_Label  ${PUSERNAME213}
    FOR  ${i}  IN RANGE   5
        ${Values}=  FakerLibrary.Words  	nb=3
        ${status}=  Run Keyword And Return Status   List Should Not Contain Duplicates   ${Values}
        Exit For Loop If  '${status}'=='True'
    END
    ${ShortValues}=  FakerLibrary.Words  	nb=3
    ${Notifmsg}=  FakerLibrary.Words  	nb=3
    ${ValueSet}=  Create ValueSet For Label  ${Values[0]}  ${ShortValues[0]}  ${Values[1]}  ${ShortValues[1]}  ${Values[2]}  ${ShortValues[2]}
    ${NotificationSet}=  Create NotificationSet For Label  ${Values[0]}  ${Notifmsg[0]}  ${Values[1]}  ${Notifmsg[1]}  ${Values[2]}  ${Notifmsg[2]}
    ${labelname}=  FakerLibrary.Words  nb=2
    ${label_desc}=  FakerLibrary.Sentence
    ${resp}=  Create Label  ${labelname[0]}  ${labelname[1]}  ${label_desc}  ${ValueSet}  ${NotificationSet}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${label_id}  ${resp.json()}

    ${resp}=  Get Label By Id  ${label_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['id']}                           ${label_id}
    Should Be Equal As Strings  ${resp.json()['label']}                        ${labelname[0]}
    Should Be Equal As Strings  ${resp.json()['displayName']}                  ${labelname[1]}
    Should Be Equal As Strings  ${resp.json()['description']}                  ${label_desc}
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['value']}         ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['shortValue']}    ${ShortValues[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['value']}         ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['shortValue']}    ${ShortValues[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['value']}         ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['shortValue']}    ${ShortValues[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['values']}    ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['messages']}  ${Notifmsg[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['values']}    ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['messages']}  ${Notifmsg[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['values']}    ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['messages']}  ${Notifmsg[2]}

    ${len}=  Get Length  ${ValueSet}
    ${i}=   Random Int   min=0   max=${len-1}
    ${label_value}=   Set Variable   ${ValueSet[${i}]['value']}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${label_dict}=  Create Label Dictionary  ${labelname[0]}  ${label_value}
    ${resp}=  Add Labels for Customers   ${label_dict}   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}   419
    Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"

JD-TC-AddCustomerLabel-UH7
    [Documentation]  Add a label by consumer login.
     
    clear_service   ${PUSERNAME213}
    clear_location  ${PUSERNAME213}
    clear_appt_schedule   ${PUSERNAME213}
    clear_customer   ${PUSERNAME213}

    ${resp}=  ProviderLogin  ${PUSERNAME213}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name   
    ${resp}=  AddCustomer  ${CUSERNAME38}   firstName=${firstname}   lastName=${lastname} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME38}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    clear_Label  ${PUSERNAME213}
    FOR  ${i}  IN RANGE   5
        ${Values}=  FakerLibrary.Words  	nb=3
        ${status}=  Run Keyword And Return Status   List Should Not Contain Duplicates   ${Values}
        Exit For Loop If  '${status}'=='True'
    END
    ${ShortValues}=  FakerLibrary.Words  	nb=3
    ${Notifmsg}=  FakerLibrary.Words  	nb=3
    ${ValueSet}=  Create ValueSet For Label  ${Values[0]}  ${ShortValues[0]}  ${Values[1]}  ${ShortValues[1]}  ${Values[2]}  ${ShortValues[2]}
    ${NotificationSet}=  Create NotificationSet For Label  ${Values[0]}  ${Notifmsg[0]}  ${Values[1]}  ${Notifmsg[1]}  ${Values[2]}  ${Notifmsg[2]}
    ${labelname}=  FakerLibrary.Words  nb=2
    ${label_desc}=  FakerLibrary.Sentence
    ${resp}=  Create Label  ${labelname[0]}  ${labelname[1]}  ${label_desc}  ${ValueSet}  ${NotificationSet}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${label_id}  ${resp.json()}

    ${resp}=  Get Label By Id  ${label_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['id']}                           ${label_id}
    Should Be Equal As Strings  ${resp.json()['label']}                        ${labelname[0]}
    Should Be Equal As Strings  ${resp.json()['displayName']}                  ${labelname[1]}
    Should Be Equal As Strings  ${resp.json()['description']}                  ${label_desc}
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['value']}         ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['shortValue']}    ${ShortValues[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['value']}         ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['shortValue']}    ${ShortValues[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['value']}         ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['shortValue']}    ${ShortValues[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['values']}    ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['messages']}  ${Notifmsg[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['values']}    ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['messages']}  ${Notifmsg[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['values']}    ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['messages']}  ${Notifmsg[2]}

    ${len}=  Get Length  ${ValueSet}
    ${i}=   Random Int   min=0   max=${len-1}
    ${label_value}=   Set Variable   ${ValueSet[${i}]['value']}

    ${resp}=  Provider Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME38}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${label_dict}=  Create Label Dictionary  ${labelname[0]}  ${label_value}
    ${resp}=  Add Labels for Customers   ${label_dict}   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-AddCustomerLabel-UH8
    [Documentation]  Add a label with empty label name.
     
    clear_service   ${PUSERNAME213}
    clear_location  ${PUSERNAME213}
    clear_appt_schedule   ${PUSERNAME213}
    clear_customer   ${PUSERNAME213}

    ${resp}=  ProviderLogin  ${PUSERNAME213}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name   
    ${resp}=  AddCustomer  ${CUSERNAME38}   firstName=${firstname}   lastName=${lastname} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME38}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    clear_Label  ${PUSERNAME213}
    FOR  ${i}  IN RANGE   5
        ${Values}=  FakerLibrary.Words  	nb=3
        ${status}=  Run Keyword And Return Status   List Should Not Contain Duplicates   ${Values}
        Exit For Loop If  '${status}'=='True'
    END
    ${ShortValues}=  FakerLibrary.Words  	nb=3
    ${Notifmsg}=  FakerLibrary.Words  	nb=3
    ${ValueSet}=  Create ValueSet For Label  ${Values[0]}  ${ShortValues[0]}  ${Values[1]}  ${ShortValues[1]}  ${Values[2]}  ${ShortValues[2]}
    ${NotificationSet}=  Create NotificationSet For Label  ${Values[0]}  ${Notifmsg[0]}  ${Values[1]}  ${Notifmsg[1]}  ${Values[2]}  ${Notifmsg[2]}
    ${labelname}=  FakerLibrary.Words  nb=2
    ${label_desc}=  FakerLibrary.Sentence
    ${resp}=  Create Label  ${labelname[0]}  ${labelname[1]}  ${label_desc}  ${ValueSet}  ${NotificationSet}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${label_id}  ${resp.json()}

    ${resp}=  Get Label By Id  ${label_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    Should Be Equal As Strings  ${resp.json()['id']}                           ${label_id}
    Should Be Equal As Strings  ${resp.json()['label']}                        ${labelname[0]}
    Should Be Equal As Strings  ${resp.json()['displayName']}                  ${labelname[1]}
    Should Be Equal As Strings  ${resp.json()['description']}                  ${label_desc}
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['value']}         ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['shortValue']}    ${ShortValues[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['value']}         ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['shortValue']}    ${ShortValues[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['value']}         ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['shortValue']}    ${ShortValues[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['values']}    ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['messages']}  ${Notifmsg[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['values']}    ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['messages']}  ${Notifmsg[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['values']}    ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['messages']}  ${Notifmsg[2]}

    ${len}=  Get Length  ${ValueSet}
    ${i}=   Random Int   min=0   max=${len-1}
    ${label_value}=   Set Variable   ${ValueSet[${i}]['value']}

    ${label_dict}=  Create Label Dictionary  ${EMPTY}  ${label_value}
    ${resp}=  Add Labels for Customers   ${label_dict}   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${LABEL_NOT_EXIST}"

JD-TC-AddCustomerLabel-UH9
    [Documentation]  Add a label with empty label value.
     
    clear_service   ${PUSERNAME213}
    clear_location  ${PUSERNAME213}
    clear_appt_schedule   ${PUSERNAME213}
    clear_customer   ${PUSERNAME213}

    ${resp}=  ProviderLogin  ${PUSERNAME213}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name   
    ${resp}=  AddCustomer  ${CUSERNAME38}   firstName=${firstname}   lastName=${lastname} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME38}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    clear_Label  ${PUSERNAME213}
    FOR  ${i}  IN RANGE   5
        ${Values}=  FakerLibrary.Words  	nb=3
        ${status}=  Run Keyword And Return Status   List Should Not Contain Duplicates   ${Values}
        Exit For Loop If  '${status}'=='True'
    END
    ${ShortValues}=  FakerLibrary.Words  	nb=3
    ${Notifmsg}=  FakerLibrary.Words  	nb=3
    ${ValueSet}=  Create ValueSet For Label  ${Values[0]}  ${ShortValues[0]}  ${Values[1]}  ${ShortValues[1]}  ${Values[2]}  ${ShortValues[2]}
    ${NotificationSet}=  Create NotificationSet For Label  ${Values[0]}  ${Notifmsg[0]}  ${Values[1]}  ${Notifmsg[1]}  ${Values[2]}  ${Notifmsg[2]}
    ${labelname}=  FakerLibrary.Words  nb=2
    ${label_desc}=  FakerLibrary.Sentence
    ${resp}=  Create Label  ${labelname[0]}  ${labelname[1]}  ${label_desc}  ${ValueSet}  ${NotificationSet}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${label_id}  ${resp.json()}

    ${resp}=  Get Label By Id  ${label_id}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['id']}                           ${label_id}
    Should Be Equal As Strings  ${resp.json()['label']}                        ${labelname[0]}
    Should Be Equal As Strings  ${resp.json()['displayName']}                  ${labelname[1]}
    Should Be Equal As Strings  ${resp.json()['description']}                  ${label_desc}
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['value']}         ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][0]['shortValue']}    ${ShortValues[0]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['value']}         ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][1]['shortValue']}    ${ShortValues[1]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['value']}         ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['valueSet'][2]['shortValue']}    ${ShortValues[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['values']}    ${Values[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][0]['messages']}  ${Notifmsg[0]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['values']}    ${Values[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][1]['messages']}  ${Notifmsg[1]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['values']}    ${Values[2]}   
    Should Be Equal As Strings  ${resp.json()['notification'][2]['messages']}  ${Notifmsg[2]}

    ${label_dict}=  Create Label Dictionary  ${labelname[0]}  ${EMPTY}
    ${resp}=  Add Labels for Customers   ${label_dict}   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${VALUE_NOT_VALID}"


JD-TC-AddCustomerLabel-11
    [Documentation]  Add multiple labels for multiple customers.

    ${resp}=  ProviderLogin  ${PUSERNAME107}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_customer   ${PUSERNAME107}
    clear_Label  ${PUSERNAME107}

    ${label_id1}=  Create Sample Label

    ${resp}=  Get Label By Id  ${label_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${label_id1}

    ${label_id2}=  Create Sample Label

    ${resp}=  Get Label By Id  ${label_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${label_id2}

    ${label_id3}=  Create Sample Label

    ${resp}=  Get Label By Id  ${label_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${label_id3}

    ${procon_ids}=  Create List

    FOR   ${a}  IN RANGE   3

        ${PO_Number}    Generate random string    3    0123456789
        ${PO_Number}    Convert To Integer  ${PO_Number}
        ${randomval}    FakerLibrary.Numerify  %%%%
        ${CUSERPH}=  Evaluate  ${CUSERNAME}+${PO_Number}+${randomval}
        Set Test Variable  ${CUSERPH${a}}  ${CUSERPH}
        ${fname}=  FakerLibrary.first_name
        ${lname}=  FakerLibrary.last_name
        ${resp}=  AddCustomer  ${CUSERPH${a}}  firstName=${fname}  lastName=${lname}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}  ${resp.json()}

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH${a}}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid${a}}
        Append To List   ${procon_ids}  ${cid${a}}

    END

    ${resp}=  Get Label By Id  ${label_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${lbl_name1}=  Set Variable   ${resp.json()['label']}
    ${len}=  Get Length  ${resp.json()['valueSet']}
    ${i}=   Random Int   min=0   max=${len-1}
    ${lbl_value1}=   Set Variable   ${resp.json()['valueSet'][${i}]['value']}

    ${resp}=  Get Label By Id  ${label_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${lbl_name2}=  Set Variable   ${resp.json()['label']}
    ${len}=  Get Length  ${resp.json()['valueSet']}
    ${i}=   Random Int   min=0   max=${len-1}
    ${lbl_value2}=   Set Variable   ${resp.json()['valueSet'][${i}]['value']}

    ${resp}=  Get Label By Id  ${label_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${lbl_name3}=  Set Variable   ${resp.json()['label']}
    ${len}=  Get Length  ${resp.json()['valueSet']}
    ${i}=   Random Int   min=0   max=${len-1}
    ${lbl_value3}=   Set Variable   ${resp.json()['valueSet'][${i}]['value']}

    ${label_dict}=  Create Label Dictionary  ${lbl_name1}  ${lbl_value1}  ${lbl_name2}  ${lbl_value2}  ${lbl_name3}  ${lbl_value3}

    ${resp}=  Add Labels for Customers   ${label_dict}  @{procon_ids}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH0}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${items}     Get Dictionary Items   ${resp.json()[0]['label']}
    FOR  ${key}    ${value}    IN    @{items}
        Run Keyword If  '${key}' == '${lbl_name1}'
        ...   Should Be Equal As Strings  ${value}  ${lbl_value1}
        ...    ELSE IF     '${key}' == '${lbl_name2}'
        ...   Should Be Equal As Strings  ${value}  ${lbl_value2}
        ...    ELSE IF     '${key}' == '${lbl_name3}'
        ...   Should Be Equal As Strings  ${value}  ${lbl_value3}

    END

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${items}     Get Dictionary Items   ${resp.json()[0]['label']}
    FOR  ${key}    ${value}    IN    @{items}
        Run Keyword If  '${key}' == '${lbl_name1}'
        ...   Should Be Equal As Strings  ${value}  ${lbl_value1}
        ...    ELSE IF     '${key}' == '${lbl_name2}'
        ...   Should Be Equal As Strings  ${value}  ${lbl_value2}
        ...    ELSE IF     '${key}' == '${lbl_name3}'
        ...   Should Be Equal As Strings  ${value}  ${lbl_value3}

    END

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${items}     Get Dictionary Items   ${resp.json()[0]['label']}
    FOR  ${key}    ${value}    IN    @{items}
        Run Keyword If  '${key}' == '${lbl_name1}'
        ...   Should Be Equal As Strings  ${value}  ${lbl_value1}
        ...    ELSE IF     '${key}' == '${lbl_name2}'
        ...   Should Be Equal As Strings  ${value}  ${lbl_value2}
        ...    ELSE IF     '${key}' == '${lbl_name3}'
        ...   Should Be Equal As Strings  ${value}  ${lbl_value3}

    END


JD-TC-AddCustomerLabel-12
    [Documentation]  Add multiple labels for single customer.

    ${resp}=  ProviderLogin  ${PUSERNAME107}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_customer   ${PUSERNAME107}
    clear_Label  ${PUSERNAME107}

    ${label_id1}=  Create Sample Label

    ${resp}=  Get Label By Id  ${label_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${label_id1}

    ${label_id2}=  Create Sample Label

    ${resp}=  Get Label By Id  ${label_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${label_id2}

    ${label_id3}=  Create Sample Label

    ${resp}=  Get Label By Id  ${label_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${label_id3}

    ${PO_Number}    Generate random string    3    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${randomval}    FakerLibrary.Numerify  %%%%
    ${CUSERPH0}=  Evaluate  ${CUSERNAME}+${PO_Number}+${randomval}
    ${fname}=  FakerLibrary.first_name
    ${lname}=  FakerLibrary.last_name
    ${resp}=  AddCustomer  ${CUSERPH0}  firstName=${fname}  lastName=${lname}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid0}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH0}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid0}
    
    ${resp}=  Get Label By Id  ${label_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${lbl_name1}=  Set Variable   ${resp.json()['label']}
    ${len}=  Get Length  ${resp.json()['valueSet']}
    ${i}=   Random Int   min=0   max=${len-1}
    ${lbl_value1}=   Set Variable   ${resp.json()['valueSet'][${i}]['value']}

    ${resp}=  Get Label By Id  ${label_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${lbl_name2}=  Set Variable   ${resp.json()['label']}
    ${len}=  Get Length  ${resp.json()['valueSet']}
    ${i}=   Random Int   min=0   max=${len-1}
    ${lbl_value2}=   Set Variable   ${resp.json()['valueSet'][${i}]['value']}

    ${resp}=  Get Label By Id  ${label_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${lbl_name3}=  Set Variable   ${resp.json()['label']}
    ${len}=  Get Length  ${resp.json()['valueSet']}
    ${i}=   Random Int   min=0   max=${len-1}
    ${lbl_value3}=   Set Variable   ${resp.json()['valueSet'][${i}]['value']}

    ${label_dict}=  Create Label Dictionary  ${lbl_name1}  ${lbl_value1}  ${lbl_name2}  ${lbl_value2}  ${lbl_name3}  ${lbl_value3}

    ${resp}=  Add Labels for Customers   ${label_dict}  ${cid0}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH0}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${items}     Get Dictionary Items   ${resp.json()[0]['label']}
    FOR  ${key}    ${value}    IN    @{items}
        Run Keyword If  '${key}' == '${lbl_name1}'
        ...   Should Be Equal As Strings  ${value}  ${lbl_value1}
        ...    ELSE IF     '${key}' == '${lbl_name2}'
        ...   Should Be Equal As Strings  ${value}  ${lbl_value2}
        ...    ELSE IF     '${key}' == '${lbl_name3}'
        ...   Should Be Equal As Strings  ${value}  ${lbl_value3}

    END


JD-TC-AddCustomerLabel-13
    [Documentation]  Add same label with different values for multiple customer.

    ${resp}=  ProviderLogin  ${PUSERNAME107}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_customer   ${PUSERNAME107}
    clear_Label  ${PUSERNAME107}

    ${label_id1}=  Create Sample Label

    ${resp}=  Get Label By Id  ${label_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${label_id1}

    ${procon_ids}=  Create List

    FOR   ${a}  IN RANGE   3

        ${PO_Number}    Generate random string    3    0123456789
        ${PO_Number}    Convert To Integer  ${PO_Number}
        ${randomval}    FakerLibrary.Numerify  %%%%
        ${CUSERPH}=  Evaluate  ${CUSERNAME}+${PO_Number}+${randomval}
        Set Test Variable  ${CUSERPH${a}}  ${CUSERPH}
        ${fname}=  FakerLibrary.first_name
        ${lname}=  FakerLibrary.last_name
        ${resp}=  AddCustomer  ${CUSERPH${a}}  firstName=${fname}  lastName=${lname}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}  ${resp.json()}

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH${a}}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid${a}}
        Append To List   ${procon_ids}  ${cid${a}}

    END

    ${resp}=  Get Label By Id  ${label_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${lbl_name1}=  Set Variable   ${resp.json()['label']}
    ${len}=  Get Length  ${resp.json()['valueSet']}
    ${i}  ${j}=    Evaluate    random.sample(range(0, ${len-1}), 2)    random
    ${lbl_value1}=   Set Variable   ${resp.json()['valueSet'][${i}]['value']}
    ${lbl_value2}=   Set Variable   ${resp.json()['valueSet'][${j}]['value']}

    ${label_dict}=  Create Label Dictionary  ${lbl_name1}  ${lbl_value1}

    ${resp}=  Add Labels for Customers   ${label_dict}  @{procon_ids}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${label_dict}=  Create Label Dictionary  ${lbl_name1}  ${lbl_value2}

    ${resp}=  Add Labels for Customers   ${label_dict}  @{procon_ids}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${label}=    Create Dictionary  ${lbl_name1}=${lbl_value2}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH0}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['label']}  ${label_dict}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['label']}  ${label_dict}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['label']}  ${label_dict}


JD-TC-AddCustomerLabel-14
    [Documentation]  Add labels for multiple customers who are jaldee consumers.
    
    FOR   ${a}  IN RANGE   20  23

        ${resp}=  Consumer Login  ${CUSERNAME${a}}  ${PASSWORD}
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200
        Set Test Variable  ${fname${a}}   ${resp.json()['firstName']}
        Set Test Variable  ${lname${a}}   ${resp.json()['lastName']}

        ${resp}=  Consumer Logout
        Log   ${resp.json()}
        Should Be Equal As Strings    ${resp.status_code}    200

    END
    
    ${resp}=  ProviderLogin  ${PUSERNAME107}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_customer   ${PUSERNAME107}
    clear_Label  ${PUSERNAME107}

    ${label_id1}=  Create Sample Label

    ${resp}=  Get Label By Id  ${label_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${label_id1}

    ${label_id2}=  Create Sample Label

    ${resp}=  Get Label By Id  ${label_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${label_id2}

    ${label_id3}=  Create Sample Label

    ${resp}=  Get Label By Id  ${label_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  id=${label_id3}

    ${procon_ids}=  Create List

    FOR   ${a}  IN RANGE   20  23

        ${resp}=  AddCustomer  ${CUSERNAME${a}}  firstName=${fname${a}}  lastName=${lname${a}}
        Log  ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}  ${resp.json()}

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid${a}}

        Append To List   ${procon_ids}  ${cid${a}}

    END

    ${resp}=  Get Label By Id  ${label_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${lbl_name1}=  Set Variable   ${resp.json()['label']}
    ${len}=  Get Length  ${resp.json()['valueSet']}
    ${i}=   Random Int   min=0   max=${len-1}
    ${lbl_value1}=   Set Variable   ${resp.json()['valueSet'][${i}]['value']}

    ${resp}=  Get Label By Id  ${label_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${lbl_name2}=  Set Variable   ${resp.json()['label']}
    ${len}=  Get Length  ${resp.json()['valueSet']}
    ${i}=   Random Int   min=0   max=${len-1}
    ${lbl_value2}=   Set Variable   ${resp.json()['valueSet'][${i}]['value']}

    ${resp}=  Get Label By Id  ${label_id3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${lbl_name3}=  Set Variable   ${resp.json()['label']}
    ${len}=  Get Length  ${resp.json()['valueSet']}
    ${i}=   Random Int   min=0   max=${len-1}
    ${lbl_value3}=   Set Variable   ${resp.json()['valueSet'][${i}]['value']}

    ${label_dict}=  Create Label Dictionary  ${lbl_name1}  ${lbl_value1}  ${lbl_name2}  ${lbl_value2}  ${lbl_name3}  ${lbl_value3}

    ${resp}=  Add Labels for Customers   ${label_dict}  @{procon_ids}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME20}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${items}     Get Dictionary Items   ${resp.json()[0]['label']}
    FOR  ${key}    ${value}    IN    @{items}
        Run Keyword If  '${key}' == '${lbl_name1}'
        ...   Should Be Equal As Strings  ${value}  ${lbl_value1}
        ...    ELSE IF     '${key}' == '${lbl_name2}'
        ...   Should Be Equal As Strings  ${value}  ${lbl_value2}
        ...    ELSE IF     '${key}' == '${lbl_name3}'
        ...   Should Be Equal As Strings  ${value}  ${lbl_value3}

    END

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME21}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${items}     Get Dictionary Items   ${resp.json()[0]['label']}
    FOR  ${key}    ${value}    IN    @{items}
        Run Keyword If  '${key}' == '${lbl_name1}'
        ...   Should Be Equal As Strings  ${value}  ${lbl_value1}
        ...    ELSE IF     '${key}' == '${lbl_name2}'
        ...   Should Be Equal As Strings  ${value}  ${lbl_value2}
        ...    ELSE IF     '${key}' == '${lbl_name3}'
        ...   Should Be Equal As Strings  ${value}  ${lbl_value3}

    END

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME22}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${items}     Get Dictionary Items   ${resp.json()[0]['label']}
    FOR  ${key}    ${value}    IN    @{items}
        Run Keyword If  '${key}' == '${lbl_name1}'
        ...   Should Be Equal As Strings  ${value}  ${lbl_value1}
        ...    ELSE IF     '${key}' == '${lbl_name2}'
        ...   Should Be Equal As Strings  ${value}  ${lbl_value2}
        ...    ELSE IF     '${key}' == '${lbl_name3}'
        ...   Should Be Equal As Strings  ${value}  ${lbl_value3}

    END
