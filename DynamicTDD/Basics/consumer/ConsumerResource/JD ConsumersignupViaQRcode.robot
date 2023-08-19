*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown    Delete All Sessions
Force Tags        ConsumerSignup
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py
Variables         /ebs/TDD/varfiles/musers.py


*** Variables ***

@{Views}  self  all  customersOnly
${CUSERPH}      ${CUSERNAME}

***Keywords***

Get branch by license
    [Arguments]   ${lic_id}
    
    ${resp}=   Get File    ${EXECDIR}/TDD/varfiles/musers.py
    ${len}=   Split to lines  ${resp}
    ${length}=  Get Length   ${len}
     
    FOR   ${a}  IN RANGE  ${length}
            
        ${Branch_PH}=  Set Variable  ${MUSERNAME${a}}
        ${resp}=  Encrypted Provider Login  ${MUSERNAME${a}}  ${PASSWORD}
        Should Be Equal As Strings    ${resp.status_code}    200

        ${decrypted_data}=  db.decrypt_data  ${resp.content}
        Log  ${decrypted_data}
        ${domain}=   Set Variable    ${decrypted_data['sector']}
        ${subdomain}=    Set Variable      ${decrypted_data['subSector']}

        # ${domain}=   Set Variable    ${resp.json()['sector']}
        # ${subdomain}=    Set Variable      ${resp.json()['subSector']}
        
        ${resp}=   Get Active License
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}   200
        ${pkg_id}=   Set Variable  ${resp.json()['accountLicense']['licPkgOrAddonId']}
        ${pkg_name}=   Set Variable  ${resp.json()['accountLicense']['name']}
	    # Run Keyword IF   ${resp.json()['accountLicense']['licPkgOrAddonId']} == ${lic_id}   AND   ${resp.json()['accountLicense']['name']} == ${lic_name}   Exit For Loop
        Exit For Loop IF  ${resp.json()['accountLicense']['licPkgOrAddonId']} == ${lic_id}

    END
    [Return]  ${Branch_PH}


*** Test Cases ***                                                                     

JD-TC-Consumer Signup-1
    [Documentation]   Create consumer via qrcode with all valid attributes 

    clear_customer   ${PUSERNAME152}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${pid}=  get_acc_id  ${PUSERNAME152}
  
    ${CUSERPH0}=  Evaluate  ${CUSERPH}+100200201
    Set Suite Variable   ${CUSERPH0}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH0}${\n}
    ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH0}+1000
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${email}=   FakerLibrary.email
    ${resp}=  Consumer SignUp Via QRcode   ${firstname}  ${lastname}  ${CUSERPH0}   ${countryCodes[0]}  ${pid}  ${email}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Activation  ${email}  1
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Set Credential  ${email}  ${PASSWORD}  1
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Consumer Login  ${CUSERPH0}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Append To File  ${EXECDIR}/TDD/consumernumbers.txt  ${CUSERPH0}${\n}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Verify Response List  ${resp}  0  firstName=${firstname}  lastName=${lastname}  phoneNo=${CUSERPH0} 
   

JD-TC-Consumer Signup-2
    [Documentation]    Create another consumer with phone number which is not activated but have done signup
    
    clear_customer   ${PUSERNAME15}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${pid}=  get_acc_id  ${PUSERNAME15}
    
    ${CUSERPH1}=  Evaluate  ${CUSERPH}+100200210
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH1}${\n}
    Set Suite Variable   ${CUSERPH1}
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${email}=   FakerLibrary.email
    ${resp}=  Consumer SignUp Via QRcode   ${firstname}  ${lastname}  ${CUSERPH1}   ${countryCodes[0]}  ${pid}  ${email}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${email}=   FakerLibrary.email
    ${resp}=  Consumer SignUp Via QRcode   ${firstname}  ${lastname}  ${CUSERPH1}   ${countryCodes[0]}  ${pid}  ${email}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Activation  ${email}  1
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Set Credential  ${email}  ${PASSWORD}  1
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERPH1}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Append To File  ${EXECDIR}/TDD/consumernumbers.txt  ${CUSERPH1}${\n}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer  
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Verify Response List  ${resp}  0  firstName=${firstname}  lastName=${lastname}  phoneNo=${CUSERPH1} 
   
JD-TC-Consumer Signup-3
    [Documentation]   Create a Consumer with existing provider's phone number

    clear_customer   ${PUSERNAME15}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pid1}=  get_acc_id  ${PUSERNAME15}
    Set Suite Variable   ${pid1}
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${email}=   FakerLibrary.email
    ${resp}=  Consumer SignUp Via QRcode   ${firstname}  ${lastname}  ${CUSERPH0}   ${countryCodes[0]}  ${pid1}  ${email}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"     "${MOBILE_NO_USED}"
    # Append To File  ${EXECDIR}/TDD/consumernumbers.txt  ${PUSERNAME5}${\n}

    # ${resp}=  Consumer Activation  ${email}  1
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Consumer Set Credential  ${PUSERNAME5}  ${PASSWORD}  1
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Consumer Login  ${PUSERNAME5}  ${PASSWORD}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Encrypted Provider Login  ${PUSERNAME15}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  GetCustomer  
    # Log   ${resp.json()}
    # Should Be Equal As Strings      ${resp.status_code}  200
    # Verify Response List  ${resp}  0  firstName=${firstname}  lastName=${lastname}  phoneNo=${PUSERNAME5} 
   
JD-TC-Consumer Signup-4
    [Documentation]   Create consumer with different country code

    clear_customer   ${PUSERNAME15}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${pid}=  get_acc_id  ${PUSERNAME15}
    
    ${CUSERPH2}=  Evaluate  ${CUSERPH}+100200206
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH2}${\n}
    Set Suite Variable   ${CUSERPH2}
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${email}=   FakerLibrary.email
    ${resp}=  Consumer SignUp Via QRcode   ${firstname}  ${lastname}  ${CUSERPH0}   ${countryCodes[2]}  ${pid}  ${email}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"     "${INVALID_PHONE}"

    # ${resp}=  Consumer Activation  ${email}  1
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Consumer Set Credential  ${CUSERPH2}  ${PASSWORD}  1
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Consumer Login  ${CUSERPH2}  ${PASSWORD}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # Append To File  ${EXECDIR}/TDD/consumernumbers.txt  ${CUSERPH2}${\n}

    # ${resp}=  Encrypted Provider Login  ${PUSERNAME15}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  GetCustomer  
    # Log   ${resp.json()}
    # Should Be Equal As Strings      ${resp.status_code}  200
    # Verify Response List  ${resp}  0  firstName=${firstname}  lastName=${lastname}  phoneNo=${CUSERPH2} 
   


JD-TC-Consumer Signup-5
    [Documentation]   sign up a provider consumer as consumer with walkinConsumerBecomesJdCons as false.
    clear_customer   ${PUSERNAME8}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME8}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    ${resp1}=   Run Keyword If  ${resp.json()['walkinConsumerBecomesJdCons']}==${bool[1]}   Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[0]}  ${EMPTY}
    Run Keyword If   '${resp1}' != '${None}'  Log  ${resp1.json()}
    Run Keyword If   '${resp1}' != '${None}'  Should Be Equal As Strings  ${resp1.status_code}  200

    ${resp}=   Get jaldeeIntegration Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['walkinConsumerBecomesJdCons']}   ${bool[0]}

    FOR   ${i}  IN RANGE   5
        ${PO_Number1}    Generate random string    3    0123456799
        ${PO_Number1}    Convert To Integer  ${PO_Number1}
        ${CUSERPH0}=  Evaluate  ${CUSERNAME}+${PO_Number1}
        ${keywordstatus} 	${value} = 	Run Keyword And Ignore Error   List Should Not Contain Value  ${numbers}  ${CUSERPH0}
        Log Many  ${keywordstatus} 	${value}
        Continue For Loop If  '${keywordstatus}' == 'FAIL'
        Run Keyword If  '${keywordstatus}' == 'PASS'  Append To List   ${numbers}  ${CUSERPH0}
        Exit For Loop IF   '${keywordstatus}' == 'PASS'
    END
    

    ${fname}=  FakerLibrary.first_name
    ${lname}=  FakerLibrary.last_name
    ${email}=   FakerLibrary.email
    # ${resp}=  AddCustomer  ${CUSERPH0}  firstName=${fname}  lastName=${lname}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${cid}  ${resp.json()}
    
    # ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH0}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer SignUp Via QRcode   ${fname}  ${lname}  ${CUSERPH0}   ${countryCodes[0]}  ${pid}  ${email}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Activation  ${email}  1
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Set Credential  ${email}  ${PASSWORD}  1  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Login  ${CUSERPH0}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Consumer Set Credential  ${email}  ${PASSWORD}  1  
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Consumer Login  ${PUSERPH0}  ${PASSWORD}  
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Consumer Logout
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Append To File  ${EXECDIR}/TDD/consumernumbers.txt  ${PUSERPH0}${\n}

    # ${resp}=  Encrypted Provider Login  ${buser}  ${PASSWORD}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  GetCustomer  
    # Log   ${resp.json()}
    # Should Be Equal As Strings      ${resp.status_code}  200
    # Verify Response List  ${resp}  0  firstName=${firstname}  lastName=${lastname}  phoneNo=${PUSERPH0} 
   
    ${resp}=  Consumer Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    Append To File  ${EXECDIR}/TDD/consumernumbers.txt  ${CUSERPH0}${\n}


    ${resp}=  Encrypted Provider Login  ${PUSERNAME8}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  GetCustomer    phoneNo-eq=${CUSERPH0}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Verify Response List  ${resp}  0  firstName=${fname}  lastName=${lname}  phoneNo=${CUSERPH0} 
   
JD-TC-Consumer Signup-6
    [Documentation]   sign up a consumer with user's phone number.

    ${licId}  ${licname}=  get_highest_license_pkg
    ${buser}=   Get branch by license   ${licId}
    
    ${resp}=  Encrypted Provider Login  ${buser}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get License UsageInfo 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=   Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}
    Set Test Variable  ${pid}  ${resp.json()['id']}


    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    
    sleep  2s
    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc1}=   FakerLibrary.word  
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp.json()}

    ${PO_Number}    Generate random string    4    0123456789
    ${PO_Number}    Convert To Integer  ${PO_Number}
    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+${PO_Number}
    clear_users  ${PUSERPH0}
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${email}=   FakerLibrary.email
    ${gender}=  Random Element    ${Genderlist}
    # ${pin}=  get_pincode

    # ${resp}=  Get LocationsByPincode     ${pin}
    FOR    ${i}    IN RANGE    3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} = 	Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
    END
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${city}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Test Variable  ${state}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Test Variable  ${pin}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    

    ${whpnum}=  Evaluate  ${PUSERPH0}+336245
    ${tlgnum}=  Evaluate  ${PUSERPH0}+336345

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERPH0}.ynwtest@netvarth.com   ${userType[0]}  ${pin}  ${countryCodes[0]}  ${PUSERPH0}  ${dep_id}  ${sub_domain_id}  ${bool[0]}  ${countryCodes[0]}  ${whpnum}  ${countryCodes[0]}  ${tlgnum}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id}  ${resp.json()}

    # ${resp}=  Get User By Id  ${u_id}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Verify Response  ${resp}  id=${u_id}  firstName=${firstname}  lastName=${lastname}  mobileNo=${PUSERPH0}  ${countryCodes[0]}  ${pid}

    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer SignUp Via QRcode   ${firstname}  ${lastname}  ${CUSERPH0}   ${countryCodes[0]}  ${pid}  ${email} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"     "${MOBILE_NO_USED}"

    # ${resp}=  Consumer Activation  ${PUSERPH0}  1
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Consumer Set Credential  ${email}  ${PASSWORD}  1  
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Consumer Login  ${PUSERPH0}  ${PASSWORD}  
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Consumer Logout
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200
    # Append To File  ${EXECDIR}/TDD/consumernumbers.txt  ${PUSERPH0}${\n}

    # ${resp}=  Encrypted Provider Login  ${buser}  ${PASSWORD}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  GetCustomer  
    # Log   ${resp.json()}
    # Should Be Equal As Strings      ${resp.status_code}  200
    # Verify Response List  ${resp}  0  firstName=${firstname}  lastName=${lastname}  phoneNo=${PUSERPH0} 

JD-TC-Consumer Signup-7
    [Documentation]   sign up a provider consumer as consumer after waitlist
    clear_customer   ${PUSERNAME82}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME82}  ${PASSWORD}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${pid}  ${resp.json()['id']}

    clear_location  ${PUSERNAME82}
    clear_queue  ${PUSERNAME82}
    Clear_service  ${PUSERNAME82}
    ${resp} =  Create Sample Queue
    Set Test Variable  ${s_id}  ${resp['service_id']}
    Set Test Variable  ${qid}   ${resp['queue_id']}
    Set Suite Variable   ${lid}   ${resp['location_id']}

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['bSchedule']['timespec'][0]['timezone']}
      
    ${CUSERPH3}=  Evaluate  ${CUSERPH}+100200204
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH3}${\n}
    ${fname}=  FakerLibrary.first_name
    ${lname}=  FakerLibrary.last_name
    ${email}=   FakerLibrary.email
    ${resp}=  AddCustomer  ${CUSERPH3}  firstName=${fname}  lastName=${lname}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${cid}  ${resp.json()}
    
    ${resp}=  GetCustomer  phoneNo-eq=${CUSERPH3}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid}

    ${DAY}=  db.get_date_by_timezone  ${tz}
    ${cnote}=   FakerLibrary.word
    ${resp}=  Add To Waitlist  ${cid}  ${s_id}  ${qid}  ${DAY}  ${cnote}  ${bool[1]}  ${cid} 
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
      
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid[0]}

    ${resp}=  GetCustomer  
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Verify Response List  ${resp}  0  firstName=${fname}  lastName=${lname}  phoneNo=${CUSERPH3} 
      
    ${resp}=  Provider Logout
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer SignUp Via QRcode  ${fname}  ${lname}  ${CUSERPH3}  ${countryCodes[0]}  ${pid}  ${email} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Activation  ${email}  1
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"     "${PRO_CON_ALREADY_EXIST}"

    # ${resp}=  Consumer Set Credential  ${email}  ${PASSWORD}  1  
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Consumer Login  ${CUSERPH3}  ${PASSWORD}  
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Consumer Logout
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # Append To File  ${EXECDIR}/TDD/consumernumbers.txt  ${CUSERPH3}${\n}

    # ${resp}=  Encrypted Provider Login  ${PUSERNAME82}  ${PASSWORD}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  GetCustomer  
    # Log   ${resp.json()}
    # Should Be Equal As Strings      ${resp.status_code}  200
    # Verify Response List  ${resp}  0  firstName=${fname}  lastName=${lname}  phoneNo=${CUSERPH3} 
      


JD-TC-Consumer Signup-UH1
    [Documentation]   Create a Consumer with empty phone number 
    
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${email} =  FakerLibrary.email
    ${resp}=  Consumer SignUp Via QRcode  ${firstname}  ${lastname}  ${EMPTY}  ${countryCodes[0]}  ${pid1}  ${email} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings  "${resp.json()}"    "${PRIMARY_PHONENO_REQUIRED}"

JD-TC-Consumer Signup-UH2
    [Documentation]   Create a Consumer with existing consumer's phone number

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${email}=   FakerLibrary.email
    ${resp}=  Consumer SignUp Via QRcode  ${firstname}  ${lastname}  ${CUSERPH1}  ${countryCodes[0]}  ${pid1}  ${email} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"     "${MOBILE_NO_USED}"


JD-TC-Consumer Signup-UH3
    [Documentation]    signup a consumer with phone number and check provider consumer then try to  add as customer
    
    clear_customer   ${PUSERNAME15}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME15}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${pid}=  get_acc_id  ${PUSERNAME15}
    
    ${CUSERPH1}=  Evaluate  ${CUSERPH}+100200204
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH1}${\n}
    Set Suite Variable   ${CUSERPH1}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${email}=   FakerLibrary.email
    ${resp}=  Consumer SignUp Via QRcode    ${firstname}  ${lastname}  ${CUSERPH1}  ${countryCodes[0]}  ${pid}  ${email} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Consumer Activation  ${email}  1
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    422

    # ${resp}=  Consumer Set Credential  ${email}  ${PASSWORD}  1
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Consumer Login  ${CUSERPH1}  ${PASSWORD}
    # Log  ${resp.content}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # Append To File  ${EXECDIR}/TDD/consumernumbers.txt  ${CUSERPH1}${\n}

    # ${resp}=  Encrypted Provider Login  ${PUSERNAME15}  ${PASSWORD}
    # Log  ${resp.json()}
    # Should Be Equal As Strings    ${resp.status_code}    200

    # ${fname}=  FakerLibrary.first_name
    # ${lname}=  FakerLibrary.last_name
    # ${resp}=  AddCustomer  ${CUSERPH1}  firstName=${fname}  lastName=${lname}
    # Log  ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"     "${PRO_CON_ALREADY_EXIST}"



JD-TC-Consumer Signup-UH4        

    [Documentation]   Create consumer via qrcode with  9 digit phone number

    clear_customer   ${PUSERNAME152}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${pid}=  get_acc_id  ${PUSERNAME152}

    ${CUSERPH0}    Generate random string    9    [NUMBERS]
    ${CUSERPH0}    Convert To Integer  ${CUSERPH0}
    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${email}=   FakerLibrary.email
    ${resp}=  Consumer SignUp Via QRcode   ${firstname}  ${lastname}  ${CUSERPH0}   ${countryCodes[0]}  ${pid}  ${email}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   422
    Should Be Equal As Strings  "${resp.json()}"     "${INVALID_PHONE}"

      


























