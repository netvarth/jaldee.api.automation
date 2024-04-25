*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        PaymentSettings
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

*** Test Cases ***

JD-TC-Get Account Payment Settings of an account-1
       [Documentation]   Provider check to Get payment settings of an account
       #${resp}=   Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD} 
       #Should Be Equal As Strings    ${resp.status_code}   200
       ${domresp}=  Get BusinessDomainsConf
       Should Be Equal As Strings  ${domresp.status_code}  200

*** Comments ***
       ${len}=  Get Length  ${domresp.json()}
       ${len}=  Evaluate  ${len}-1
       Set Suite Variable  ${d1}  ${domresp.json()[${len}]['domain']}    
       Set Suite Variable  ${sd}  ${domresp.json()[${len}]['subDomains'][0]['subDomain']} 
       ${firstname}=  FakerLibrary.first_name
       ${lastname}=  FakerLibrary.last_name
       ${PUSERNAME_B}=  Evaluate  ${PUSERNAME}+550053
       ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd}  ${PUSERNAME_B}    4
       Log  ${resp.json()}
       #Set Test Variable  ${fname}  ${resp.json()['userProfile']['firstName']}
       Should Be Equal As Strings    ${resp.status_code}    200
       ${resp}=  Account Activation  ${PUSERNAME_B}  0
       Should Be Equal As Strings    ${resp.status_code}    200
       ${resp}=  Account Set Credential  ${PUSERNAME_B}  ${PASSWORD}  0
       Should Be Equal As Strings    ${resp.status_code}    200
       ${resp}=  Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD}
       Log  ${resp.json()}
       Should Be Equal As Strings    ${resp.status_code}    200
       Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERNAME_B}${\n}
       Set Suite Variable  ${PUSERNAME_B}
       ${DAY1}=  db.get_date_by_timezone  ${tz}
       Set Suite Variable  ${DAY1}  ${DAY1}
       ${list}=  Create List  1  2  3  4  5  6  7
       Set Suite Variable  ${list}  ${list}
       ${resp}=  Create Business Profile without details  ${EMPTY}  ${EMPTY}   ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}
       Should Be Equal As Strings  ${resp.status_code}  200
        

       
       ${PUSEREMAIL}=  Set Variable  ${P_Email}${PUSERNAME_B}.${test_mail}
       ${resp}=  Send Verify Login   ${PUSEREMAIL}
       Should Be Equal As Strings  ${resp.status_code}  200
       ${resp}=  Verify Login   ${PUSEREMAIL}  4
       Should Be Equal As Strings  ${resp.status_code}  200
       ${panCardNumber}=  Generate_pan_number
       ${bankAccountNumber}=  Generate_random_value  size=16  chars=string.digits
       ${bankName}=  FakerLibrary.company
       ${ifsc}=  Generate_ifsc_code
       ${panname}=  FakerLibrary.name
       ${city}=   get_place
       ${businessStatus}=   Random Element   ${businessStatus}  
       ${accounttype}=  Random Element   ${accounttype} 
       ${resp}=   Update Account Payment Settings    ${bool[0]}  ${bool[0]}  ${bool[1]}  ${EMPTY}  ${panCardNumber}  ${bankAccountNumber}  ${bankName}  ${ifsc}  ${panname}  ${firstname}  ${city}  ${businessStatus}  ${accounttype}   
       Log   ${resp.json()}
       Should Be Equal As Strings    ${resp.status_code}   200
       ${acct_id1}=  get_acc_id  ${PUSERNAME_B} 
       ${resp}=  payuVerify  ${acct_id1}
       ${resp}=   Update Account Payment Settings   ${bool[1]}  ${bool[0]}  ${bool[1]}  ${PUSERNAME_B}   ${panCardNumber}  ${bankAccountNumber}  ${bankName}  ${ifsc}  ${panname}  ${firstname}  ${city}  ${businessStatus}  ${accounttype}   
       Log   ${resp.json()}
       Should Be Equal As Strings    ${resp.status_code}   200
       ${resp}=   Get Account Payment Settings 
       Log   ${resp.json()}
       Should Be Equal As Strings    ${resp.status_code}   200
       Verify Response   ${resp}  onlinePayment=${bool[1]}  payTm=${bool[0]}  dcOrCcOrNb=${bool[1]}  payTmLinkedPhoneNumber=${PUSERNAME_B}  panCardNumber=${panCardNumber}  bankAccountNumber=${bankAccountNumber}  payUVerified=${bool[1]}  payTmVerified=${bool[0]}  bankName=${bankName}  ifscCode=${ifsc}  nameOnPanCard=${panname}  accountHolderName=${firstname}  branchCity=${city}  businessFilingStatus=${businessStatus}  accountType=${accounttype}
       
JD-TC-Get Account Payment Settings of an account-2
       [Documentation]   Provider check to Get payment of an account with payUverified=false when changing any of field in payment settings
       ${resp}=   Encrypted Provider Login  ${PUSERNAME_B}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       ${acct_id1}=  get_acc_id  ${PUSERNAME_B} 
       ${businessStatus}=   Random Element   ${businessStatus}  
       ${accounttype}=  Random Element   ${accounttype} 
       ${resp}=   Update Account Payment Settings  ${bool[0]}  ${bool[1]}  ${bool[0]}  ${PUSERNAME_B}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${EMPTY}  ${businessStatus}  ${accounttype}
       Log   ${resp.json()}
       Should Be Equal As Strings    ${resp.status_code}   200
       ${resp}=  payuVerify  ${acct_id1}
       ${resp}=   Get Account Payment Settings 
       Log   ${resp.json()}
       Should Be Equal As Strings    ${resp.status_code}   200
       Verify Response   ${resp}  onlinePayment=${bool[0]}	payTm=${bool[1]}	dcOrCcOrNb=${bool[0]}	payTmLinkedPhoneNumber=${PUSERNAME_B}	panCardNumber=${EMPTY}	bankAccountNumber=${EMPTY}	payUVerified=${bool[1]}	payTmVerified=${bool[0]}	 bankName=${EMPTY} 	ifscCode=${EMPTY}  	nameOnPanCard=${EMPTY}  	accountHolderName=${EMPTY}	branchCity=${EMPTY}            
       
JD-TC-Get Account Payment Settings of an account-UH1
       [Documentation]   Consumer check to Get payment settings of an account
       ${resp}=   ConsumerLogin  ${CUSERNAME2}  ${PASSWORD} 
       Should Be Equal As Strings    ${resp.status_code}   200
       ${resp}=   Get Account Payment Settings 
       Should Be Equal As Strings  "${resp.json()}"    "${LOGIN_NO_ACCESS_FOR_URL}"
       Should Be Equal As Strings    ${resp.status_code}   401
       
JD-TC-Get Account Payment Settings of an account-UH2
       [Documentation]   Provider check to Get payment settings of an account without login
       ${resp}=   Get Account Payment Settings 
       Should Be Equal As Strings    ${resp.status_code}   419
       Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"
       
