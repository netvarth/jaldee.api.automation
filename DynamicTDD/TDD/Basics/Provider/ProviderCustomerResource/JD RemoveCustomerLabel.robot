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

JD-TC-RemoveCustomerLabel-1
    [Documentation]  Add a label for a customer then remove the label.

    clear_service   ${PUSERNAME203}
    clear_location  ${PUSERNAME203}
    clear_appt_schedule   ${PUSERNAME203}
    clear_customer   ${PUSERNAME203}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME203}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name   
    ${resp}=  AddCustomer  ${CUSERNAME38}   firstName=${firstname}   lastName=${lastname} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME38}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    clear_Label  ${PUSERNAME203}
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
    Set Suite Variable  ${labelname}
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
    ${resp}=  Add Labels for Customers    ${label_dict}   ${cid}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${len}=  Get Length  ${ValueSet}
    # ${i}=   Random Int   min=0   max=${len-1}
    # ${label_value}=   Set Variable   ${ValueSet[${i}]['value']}
    # ${label_dict}=  Create Label Dictionary  ${labelname[0]}  ${label_value}
    # ${resp}=  Add Labels for Customers   ${label_dict}   ${cid}
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200


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

JD-TC-RemoveCustomerLabel-2
    [Documentation]  Remove one label from two labels of a customer.
     
    clear_service   ${PUSERNAME216}
    clear_location  ${PUSERNAME216}
    clear_appt_schedule   ${PUSERNAME216}
    clear_customer   ${PUSERNAME216}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME216}  ${PASSWORD}
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
    ${resp}=  Add Labels for Customers    ${label_dict}   ${cid}
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
    ${resp}=  Add Labels for Customers    ${label_dict}   ${cid}
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
    
    ${resp}=  Remove Customer Label   ${cid}  ${labelname1[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME38}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200

    Dictionary Should Contain Key   ${resp.json()[0]['label']}  ${labelname[0]}  
    Dictionary Should Contain Value   ${resp.json()[0]['label']}   ${label_value}
    Dictionary Should Not Contain Key   ${resp.json()[0]['label']}  ${labelname1[0]}
    Dictionary Should Not Contain Value   ${resp.json()[0]['label']}   ${label_value1}

JD-TC-RemoveCustomerLabel-UH1

    [Documentation]  Remove a customer label without login

    ${resp}=  Remove Customer Label   ${cid}  ${labelname[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"

JD-TC-RemoveCustomerLabel-UH2

    [Documentation]  Remove customer label by consumer login

    ${resp}=  ConsumerLogin  ${CUSERNAME15}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Remove Customer Label   ${cid}  ${labelname[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"    "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-RemoveCustomerLabel-UH3

    [Documentation]  Remove a label from a non existant Customer 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME257}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_customer   ${PUSERNAME257}

    ${resp}=  Remove Customer Label   ${cid}  ${labelname[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"   "${NO_PERMISSION}"

JD-TC-RemoveCustomerLabel-UH4

    [Documentation]  Remove a non existant label from a customer 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME203}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${labelname}=  FakerLibrary.Word
    ${resp}=  Remove Customer Label   ${cid}  ${labelname}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "This Label not applied"

JD-TC-RemoveCustomerLabel-UH5

    [Documentation]  Remove an already removed customer label 

    ${resp}=  Encrypted Provider Login  ${PUSERNAME203}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Remove Customer Label   ${cid}  ${labelname[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "This Label not applied"










