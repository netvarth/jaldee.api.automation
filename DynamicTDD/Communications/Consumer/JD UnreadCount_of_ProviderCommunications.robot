*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        ProviderCommunication
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py


*** Test Cases ***


JD-TC-Unread Count of Provider Communications-INDEPENDENT_SP-1
    [Documentation]  When a Provider communicate with a consumer (Read messages individually)
    ${cR_id1}=  get_id  ${CUSERNAME28}
    Set Suite Variable  ${cR_id1}  ${cR_id1}
    clear_Consumermsg  ${CUSERNAME28}

    ${resp}=   Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pR_id1}  ${decrypted_data['id']}

    # Set Suite Variable  ${pR_id1}  ${resp.json()['id']}
    ${account_id1}=  get_acc_id  ${PUSERNAME1}
    Set Suite Variable  ${account_id1}

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
        Should Be Equal As Strings  ${resp1.status_code}  200
    ELSE IF    '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[1]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    clear_customer   ${PUSERNAME4}
    ${resp}=  AddCustomer  ${CUSERNAME3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${emptylist}=  Create List
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME28}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME28} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${cid28}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${cid28}  ${resp.json()[0]['id']}
    END

 
    # ${msg1}=   FakerLibrary.Word
    # ${resp}=  Communication consumers   ${cR_id1}  ${msg1}   
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200  
    # ${msg2}=   FakerLibrary.Word
    # ${resp}=  Communication consumers   ${cR_id1}  ${msg2}   
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME1}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg1}=  Fakerlibrary.sentence
    ${caption1}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralCommunicationWithConsumer   ${cookie}   ${cR_id1}  ${msg1}  ${messageType[0]}  ${caption1}  ${EMPTY}  ${EMPTY}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${msg2}=  Fakerlibrary.sentence
    ${caption2}=  Fakerlibrary.sentence
    ${resp}=  Imageupload.GeneralCommunicationWithConsumer   ${cookie}   ${cR_id1}  ${msg2}  ${messageType[0]}  ${caption2}  ${EMPTY}  ${EMPTY}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME28}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    ${resp}=  Get Consumer Communications
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    Verify Response List  ${resp}  0  accountId=${account_id1}  msg=${msg1}
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}    0
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}    ${cR_id1}
    Set Test Variable  ${msgId1}  ${resp.json()[0]['messageId']}
    
    Verify Response List  ${resp}  1  accountId=${account_id1}  msg=${msg2}
    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}    0
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}    ${cR_id1}
    Set Test Variable  ${msgId2}  ${resp.json()[1]['messageId']}

    ${resp}=  Get Consumer Communications Unread Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.json()}  2
    Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Reading Provider Communications  ${pR_id1}  ${account_id1}  ${msgId1} 
    ${resp}=  Reading Provider Communications  0  ${account_id1}  ${msgId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer Communications Unread Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.json()}  1
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${resp}=  Reading Provider Communications  ${pR_id1}  ${account_id1}  ${msgId2}
    ${resp}=  Reading Provider Communications  0  ${account_id1}  ${msgId2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer Communications Unread Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.json()}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_Consumermsg  ${CUSERNAME28} 
    ${resp}=   Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-Unread Count of Provider Communications-INDEPENDENT_SP-2
    [Documentation]  When a Provider communicate with a consumer (Read messages through a single step)
    ${cR_id1}=  get_id  ${CUSERNAME28}
    Set Suite Variable  ${cR_id1}  ${cR_id1}
    clear_Consumermsg  ${CUSERNAME28}

    ${resp}=   Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # Set Suite Variable  ${pR_id1}  ${resp.json()['id']}

      ${c_id}=  get_id  ${CUSERNAME28}
    Set Suite Variable   ${c_id} 
    clear_Consumermsg  ${CUSERNAME28}

    # ${msg1}=   FakerLibrary.Word
    # ${resp}=  Communication consumers   ${cR_id1}  ${msg1}   
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200  
    # ${msg2}=   FakerLibrary.Word
    # ${resp}=  Communication consumers   ${cR_id1}  ${msg2}   
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # ${msg3}=   FakerLibrary.Word
    # ${resp}=  Communication consumers   ${cR_id1}  ${msg3}   
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME1}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg1}=  Fakerlibrary.sentence
    ${caption1}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralCommunicationWithConsumer   ${cookie}   ${cR_id1}  ${msg1}  ${messageType[0]}  ${caption1}  ${EMPTY}  ${EMPTY}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${msg2}=  Fakerlibrary.sentence
    ${caption2}=  Fakerlibrary.sentence
    ${resp}=  Imageupload.GeneralCommunicationWithConsumer   ${cookie}   ${cR_id1}  ${msg2}  ${messageType[0]}  ${caption2}  ${EMPTY}  ${EMPTY}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg3}=  Fakerlibrary.sentence
    ${caption3}=  Fakerlibrary.sentence
    ${resp}=  Imageupload.GeneralCommunicationWithConsumer   ${cookie}   ${cR_id1}  ${msg3}  ${messageType[0]}  ${caption3}  ${EMPTY}  ${EMPTY}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME28}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    ${resp}=  Get Consumer Communications
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200



    Verify Response List  ${resp}  0  accountId=${account_id1}  msg=${msg1}
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}    0
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}    ${cR_id1}
    Set Test Variable  ${msgId1}  ${resp.json()[0]['messageId']}
    
    Verify Response List  ${resp}  1  accountId=${account_id1}  msg=${msg2}
    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}    0
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}    ${cR_id1}
    Set Test Variable  ${msgId2}  ${resp.json()[1]['messageId']}

    Verify Response List  ${resp}  2  accountId=${account_id1}  msg=${msg3}
    Should Be Equal As Strings  ${resp.json()[2]['owner']['id']}    0
    Should Be Equal As Strings  ${resp.json()[2]['receiver']['id']}    ${cR_id1}
    Set Test Variable  ${msgId3}  ${resp.json()[2]['messageId']}


    ${resp}=  Get Consumer Communications Unread Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.json()}  3
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Reading Provider Communications  0  ${account_id1}  ${msgId1}-${msgId2}-${msgId3} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer Communications Unread Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.json()}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_Consumermsg  ${CUSERNAME28} 
    ${resp}=   Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200



JD-TC-Unread Count of Provider Communications-INDEPENDENT_SP-3
    [Documentation]  When multiple number of Providers communicate with a consumer
    clear_Consumermsg  ${CUSERNAME28}
    ${resp}=   Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    # ${msg1}=   FakerLibrary.Word
    # ${resp}=  Communication consumers   ${cR_id1}  ${msg1}   
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME1}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg1}=  Fakerlibrary.sentence
    ${caption1}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralCommunicationWithConsumer   ${cookie}   ${cR_id1}  ${msg1}  ${messageType[0]}  ${caption1}  ${EMPTY}  ${EMPTY}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Encrypted Provider Login  ${PUSERNAME2}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pR_id2}  ${decrypted_data['id']}

    # Set Suite Variable  ${pR_id2}  ${resp.json()['id']}
    ${account_id2}=  get_acc_id  ${PUSERNAME2}
    Set Suite Variable  ${account_id2}  ${account_id2}
    # ${msg2}=   FakerLibrary.Word

     ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
        Should Be Equal As Strings  ${resp1.status_code}  200
    ELSE IF    '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[1]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}

    clear_customer   ${PUSERNAME4}
    ${resp}=  AddCustomer  ${CUSERNAME3}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
    ${emptylist}=  Create List
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME28}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME28} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${cid28}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${cid28}  ${resp.json()[0]['id']}
    END
    # ${resp}=  Communication consumers   ${cR_id1}  ${msg2}   
    # Log   ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME2}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg2}=  Fakerlibrary.sentence
    ${caption2}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralCommunicationWithConsumer   ${cookie}   ${cR_id1}  ${msg2}  ${messageType[0]}  ${caption2}  ${EMPTY}  ${EMPTY}    
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME28}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    ${resp}=  Get Consumer Communications
    Log   ${resp.json()}

    Verify Response List  ${resp}  0  accountId=${account_id1}  msg=${msg1}
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}    0
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}    ${cR_id1}
    Set Test Variable  ${msgId1}  ${resp.json()[0]['messageId']}

    Verify Response List  ${resp}  1  accountId=${account_id2}  msg=${msg2}
    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}    0
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}    ${cR_id1}
    Set Test Variable  ${msgId2}  ${resp.json()[1]['messageId']}

    ${resp}=  Get Consumer Communications Unread Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.json()}  2
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Reading Provider Communications  0  ${account_id1}  ${msgId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer Communications Unread Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.json()}  1
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Reading Provider Communications  0  ${account_id1}  ${msgId2}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Communications Unread Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.json()}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_Consumermsg  ${CUSERNAME28}
    ${resp}=   Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200



JD-TC-Unread Count of Provider Communications-INDEPENDENT_SP-4
    [Documentation]  When a single provider communicate with multiple number of consumers
    ${cR_id2}=  get_id  ${CUSERNAME29}
    Set Suite Variable  ${cR_id2}  ${cR_id2}
    clear_Consumermsg  ${CUSERNAME28}
    clear_Consumermsg  ${CUSERNAME29}

    ${resp}=   Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

      ${emptylist}=  Create List
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME29}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME29} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${cid29}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${cid29}  ${resp.json()[0]['id']}
    END

    # ${msg1}=   FakerLibrary.Word
    # ${resp}=  Communication consumers   ${cR_id1}  ${msg1}   
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200  
    # ${msg2}=   FakerLibrary.Word
    # ${resp}=  Communication consumers   ${cR_id2}  ${msg2}   
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=  Imageupload.spLogin  ${PUSERNAME1}   ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg1}=  Fakerlibrary.sentence
    ${caption1}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralCommunicationWithConsumer   ${cookie}   ${cR_id1}  ${msg1}  ${messageType[0]}  ${caption1}  ${EMPTY}  ${EMPTY}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg2}=  Fakerlibrary.sentence
    ${caption2}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralCommunicationWithConsumer   ${cookie}   ${cR_id2}  ${msg2}  ${messageType[0]}  ${caption2}  ${EMPTY}  ${EMPTY}   
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME28}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer Communications
    Log   ${resp.json()}
    Verify Response List  ${resp}  0  accountId=${account_id1}  msg=${msg1}
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}    0
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}    ${cR_id1}
    Set Suite Variable  ${msgId1}  ${resp.json()[0]['messageId']}
    ${resp}=  Get Consumer Communications Unread Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.json()}  1
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep   1s
    ${resp}=  Reading Provider Communications  0  ${account_id1}  ${msgId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer Communications Unread Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.json()}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME29}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Communications
    Log   ${resp.json()}
    Verify Response List  ${resp}  0  accountId=${account_id1}  msg=${msg2}
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}    0
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}    ${cR_id2}
    Set Suite Variable  ${msgId2}  ${resp.json()[0]['messageId']}
    ${resp}=  Get Consumer Communications Unread Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.json()}  1
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Reading Provider Communications  0  ${account_id1}  ${msgId2}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Consumer Communications Unread Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.json()}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


JD-TC-Unread Count of Provider Communications-UH1
    [Documentation]  Communications unread count checking without  consumer login
    ${resp}=  Get Consumer Communications Unread Count
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"




JD-TC-Unread Count of Provider Communications-BRANCH-5
    [Documentation]  When a Users communicate with a consumer
    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Test Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Test Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    ${firstname_A}=  FakerLibrary.first_name
    Set Suite Variable  ${firstname_A}
    ${lastname_A}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname_A}
    ${MUSERNAME_E1}=  Evaluate  ${MUSERNAME}+6081207
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_E1}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${MUSERNAME_E1}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${MUSERNAME_E1}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${MUSERNAME_E1}${\n}
    Set Suite Variable  ${MUSERNAME_E1}
    ${id}=  get_id  ${MUSERNAME_E1}
    Set Suite Variable  ${id}
    ${bs}=  FakerLibrary.bs
    Set Suite Variable  ${bs}


    
    ${ph1}=  Evaluate  ${MUSERNAME_E1}+1000000000
    ${ph2}=  Evaluate  ${MUSERNAME_E1}+2000000000
    ${views}=  Random Element    ${Views}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}181.${test_mail}  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ${bool}
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    # ${sTime}=  add_timezone_time  ${tz}  0  15  
    # Set Suite Variable   ${sTime}
    # ${eTime}=  add_timezone_time  ${tz}  0  45  
    # Set Suite Variable   ${eTime}
    ${sTime}=  db.subtract_timezone_time  ${tz}  0  30
    # ${sTime}=  db.subtract_timezone_time  ${tz}  0  05
    Set Suite Variable  ${BsTime30}  ${sTime}
    # ${eTime}=  db.subtract_timezone_time  ${tz}  1  00
    ${eTime}=  add_timezone_time  ${tz}  1  00  
    Set Suite Variable  ${BeTime30}  ${eTime}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    ${resp}=  Update Business Profile with schedule    ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Set Test Variable  ${email_id}  ${P_Email}${MUSERNAME_E1}.${test_mail}

    ${resp}=  Update Email   ${id}   ${firstname_A}  ${lastname_A}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    sleep   02s

    ${fields}=   Get subDomain level Fields  ${domains}  ${sub_domains}
    Log  ${fields.content}
    Should Be Equal As Strings    ${fields.status_code}   200

    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}

    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sub_domains}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get specializations Sub Domain  ${domains}  ${sub_domains}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${spec}=  get_Specializations  ${resp.json()}
    
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    
    sleep  2s
    ${resp}=  Get Departments
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
     
    ${location}=  FakerLibrary.city
    Set Suite Variable  ${location}
    ${state}=  FakerLibrary.state
    Set Suite Variable  ${state}
    
    # ${number1}=  Random Int  min=1000  max=2000
    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+508197
    clear_users  ${PUSERNAME_U1}
    Set Suite Variable  ${PUSERNAME_U1}
    ${firstname1}=  FakerLibrary.name
    Set Suite Variable  ${firstname1}
    ${lastname1}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname1}
    ${dob1}=  FakerLibrary.Date
    Set Suite Variable  ${dob1}
    ${pin1}=  get_pincode

    ${whpnum}=  Evaluate  ${PUSERNAME_U1}+306245
    ${tlgnum}=  Evaluate  ${PUSERNAME_U1}+306345

    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob1}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin1}  ${countryCodes[0]}  ${PUSERNAME_U1}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${whpnum}  ${countryCodes[0]}  ${tlgnum}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id1}  ${resp.json()}

    # ${number2}=  Random Int  min=2500  max=3500
    ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+507287
    clear_users  ${PUSERNAME_U2}
    Set Suite Variable  ${PUSERNAME_U2}
    ${firstname2}=  FakerLibrary.name
    Set Suite Variable  ${firstname2}
    ${lastname2}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname2}
    ${dob2}=  FakerLibrary.Date
    Set Suite Variable  ${dob2}
    ${pin2}=  get_pincode

    ${whpnum}=  Evaluate  ${PUSERNAME_U2}+336245
    ${tlgnum}=  Evaluate  ${PUSERNAME_U2}+336345

    ${resp}=  Create User  ${firstname2}  ${lastname2}  ${dob2}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U2}.${test_mail}   ${userType[0]}  ${pin2}  ${countryCodes[0]}  ${PUSERNAME_U2}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${whpnum}  ${countryCodes[0]}  ${tlgnum}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id2}  ${resp.json()}

    ${resp}=  Get User
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${p2_id}   ${resp.json()[0]['id']}
    Set Suite Variable   ${p1_id}   ${resp.json()[1]['id']}
    Set Suite Variable   ${p0_id}   ${resp.json()[2]['id']}



    ${cR_id1}=  get_id  ${CUSERNAME28}
    Set Suite Variable  ${cR_id1}  ${cR_id1}
    clear_Consumermsg  ${CUSERNAME28}

    ${resp}=   Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pR_id1}  ${decrypted_data['id']}

    # Set Suite Variable  ${pR_id1}  ${resp.json()['id']}
    ${account_id1}=  get_acc_id  ${MUSERNAME_E1}
    Set Suite Variable  ${account_id1}

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF  '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[0]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
        Should Be Equal As Strings  ${resp1.status_code}  200
    ELSE IF    '${resp.json()['walkinConsumerBecomesJdCons']}'=='${bool[0]}' and '${resp.json()['onlinePresence']}'=='${bool[1]}'
        ${resp1}=   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[1]}


    ${emptylist}=  Create List
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME28}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME28} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${cid28}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${cid28}  ${resp.json()[0]['id']}
    END

    # ${msg1}=   FakerLibrary.Word
    # ${resp}=  Communication consumers   ${cR_id1}  ${msg1}   
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    # ${resp}=  User Consumer Communication    ${p1_id}  ${cR_id1}  ${msg1}   
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200


    # ${msg2}=   FakerLibrary.Word
    # ${resp}=  User Consumer Communication    ${p2_id}   ${cR_id1}  ${msg2}   
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=   Imageupload.spLogin  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${msg1}=  Fakerlibrary.sentence
    ${caption1}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralUserCommunicationWithConsumer   ${cookie}   ${p1_id}  ${cR_id1}  ${msg1}  ${messageType[0]}  ${caption1}  ${EMPTY}  ${EMPTY}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg2}=   FakerLibrary.Word
    ${caption2}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralUserCommunicationWithConsumer   ${cookie}   ${p2_id}  ${cR_id1}  ${msg2}  ${messageType[0]}  ${caption2}  ${EMPTY}  ${EMPTY}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME28}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    ${resp}=  Get Consumer Communications
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    Verify Response List  ${resp}  0  accountId=${account_id1}  msg=${msg1}
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}    ${p1_id}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}    ${cR_id1}
    Set Test Variable  ${msgId1}  ${resp.json()[0]['messageId']}
    
    Verify Response List  ${resp}  1  accountId=${account_id1}  msg=${msg2}
    Should Be Equal As Strings  ${resp.json()[1]['owner']['id']}    ${p2_id}
    Should Be Equal As Strings  ${resp.json()[1]['receiver']['id']}    ${cR_id1}
    Set Test Variable  ${msgId2}  ${resp.json()[1]['messageId']}

    ${resp}=  Get Consumer Communications Unread Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.json()}  2
    Should Be Equal As Strings    ${resp.status_code}    200
    # ${resp}=  Reading Provider Communications  ${pR_id1}  ${account_id1}  ${msgId1} 
    ${resp}=  Reading Provider Communications  ${p1_id}  ${account_id1}  ${msgId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer Communications Unread Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.json()}  1
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${resp}=  Reading Provider Communications  ${pR_id1}  ${account_id1}  ${msgId2}
    ${resp}=  Reading Provider Communications  ${p2_id}  ${account_id1}  ${msgId2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer Communications Unread Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.json()}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    clear_Consumermsg  ${CUSERNAME28} 
    ${resp}=   Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200




JD-TC-Unread Count of Provider Communications-BRANCH-6
    [Documentation]  When a User with multiple number of consumers
    ${cR_id5}=  get_id  ${CUSERNAME29}
    ${cR_id7}=  get_id  ${CUSERNAME30}
    clear_Consumermsg  ${CUSERNAME30}
    clear_Consumermsg  ${CUSERNAME29}

    ${resp}=   Encrypted Provider Login  ${MUSERNAME_E1}  ${PASSWORD} 
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${emptylist}=  Create List
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME30}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME30} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${cid30}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${cid30}  ${resp.json()[0]['id']}
    END

    ${emptylist}=  Create List
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME29}  
    Log  ${resp.content}
    Should Be Equal As Strings      ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${resp1}=  AddCustomer  ${CUSERNAME29} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${cid29}   ${resp1.json()}
    ELSE
        Set Suite Variable  ${cid29}  ${resp.json()[0]['id']}
    END
    # ${msg1}=   FakerLibrary.Word
    # ${resp}=  User Consumer Communication    ${p1_id}   ${cR_id7}  ${msg1}   
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200  
    # ${msg2}=   FakerLibrary.Word
    # ${resp}=  User Consumer Communication    ${p1_id}   ${cR_id5}  ${msg2}   
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${cookie}  ${resp}=   Imageupload.spLogin  ${MUSERNAME_E1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${msg1}=  Fakerlibrary.sentence
    ${caption1}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralUserCommunicationWithConsumer   ${cookie}   ${p1_id}  ${cR_id7}  ${msg1}  ${messageType[0]}  ${caption1}  ${EMPTY}  ${EMPTY}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${msg2}=   FakerLibrary.Word
    ${caption2}=  Fakerlibrary.sentence
    
    ${resp}=  Imageupload.GeneralUserCommunicationWithConsumer   ${cookie}   ${p1_id}  ${cR_id5}  ${msg2}  ${messageType[0]}  ${caption2}  ${EMPTY}  ${EMPTY}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   ProviderLogout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME30}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer Communications
    Log   ${resp.json()}
    Verify Response List  ${resp}  0  accountId=${account_id1}  msg=${msg1}
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}    ${p1_id}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}    ${cR_id7}
    Set Suite Variable  ${msgId1}  ${resp.json()[0]['messageId']}
    ${resp}=  Get Consumer Communications Unread Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.json()}  1
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Reading Provider Communications  ${p1_id}   ${account_id1}  ${msgId1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Consumer Communications Unread Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.json()}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERNAME29}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Consumer Communications
    Log   ${resp.json()}
    Verify Response List  ${resp}  0  accountId=${account_id1}  msg=${msg2}
    Should Be Equal As Strings  ${resp.json()[0]['owner']['id']}    ${p1_id}
    Should Be Equal As Strings  ${resp.json()[0]['receiver']['id']}    ${cR_id5}
    Set Suite Variable  ${msgId2}  ${resp.json()[0]['messageId']}
    ${resp}=  Get Consumer Communications Unread Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.json()}  1
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Reading Provider Communications  ${p1_id}   ${account_id1}  ${msgId2}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Consumer Communications Unread Count
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.json()}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=   Consumer Logout
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


