*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        customercount
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 


*** Test Cases ***
JD-TC-Get Customer count-1
    [Documentation]  Add Customer-1

    ${resp}=  ProviderLogin  ${PUSERNAME77}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    # ${pid}=  get_acc_id  ${PUSERNAME6}
    # Set Suite Variable  ${pid}  ${pid}
    # Should Be Equal As Strings    ${resp.status_code}   200

    ${f_name1}=   FakerLibrary.first_name
    Set Suite Variable   ${f_name1}
    ${l_name1}=   FakerLibrary.last_name
    Set Suite Variable   ${l_name1}
    ${dob}=      FakerLibrary.date
    ${phoneno}=    FakerLibrary.Random Int    min=1000000000   max=9999999999
    Set Suite Variable   ${phoneno}
    Set Suite Variable  ${email}  ${f_name1}${phoneno}${C_Email}.${test_mail}
    ${resp}=  AddCustomer with email   ${f_name1}  ${l_name1}  ${EMPTY}  ${email}  ${Genderlist[1]}  ${dob}  ${phoneno}  ${EMPTY}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${c1}  ${resp.json()}
    Log   ${resp.json()}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${phoneno}${\n}

    ${f_name}=   FakerLibrary.first_name
    # ${l_name}=   FakerLibrary.last_name
    # Set Suite Variable   ${l_name}
    ${dob}=      FakerLibrary.date
    Set Suite Variable  ${dob}
    ${phone}=    FakerLibrary.Random Int    min=1000000000   max=9999999999
    ${resp}=  AddCustomer without email  ${f_name}  ${l_name1}  ${EMPTY}   ${Genderlist[1]}  ${dob}   ${phone}  ${EMPTY}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${c2}  ${resp.json()}
    Log   ${resp.json()}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${phone}${\n}
    ${f_name}=   FakerLibrary.first_name
    ${l_name}=   FakerLibrary.last_name
    ${dob}=      FakerLibrary.date
    ${phone1}=    FakerLibrary.Random Int    min=1000000000   max=9999999999
    Set Suite Variable   ${phone1}
    ${resp}=  AddCustomer without email  ${f_name}  ${l_name}  ${EMPTY}  ${Genderlist[1]}  ${dob}  ${phone1}  ${EMPTY}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${c3}  ${resp.json()}
    Log   ${resp.json()}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${phone1}${\n}
    ${f_name2}=   FakerLibrary.first_name
    Set Suite Variable   ${f_name2}
    ${l_name}=   FakerLibrary.last_name
    ${dob}=      FakerLibrary.date
    ${phone3}=    FakerLibrary.Random Int    min=1000000000   max=9999999999
    Set Suite Variable   ${phone3}
    ${resp}=  AddCustomer without email  ${f_name2}  ${l_name}  ${EMPTY}  ${Genderlist[1]}  ${dob}  ${phone3}  ${EMPTY}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${c4}  ${resp.json()}
    Log   ${resp.json()}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${phone3}${\n}
    ${l_name}=   FakerLibrary.last_name
    ${dob}=      FakerLibrary.date
    ${phone2}=    FakerLibrary.Random Int    min=1000000000   max=9999999999
    Set Suite Variable   ${phone2}
    ${resp}=  AddCustomer without email  ${f_name1}  ${l_name}  ${EMPTY}  ${Genderlist[1]}  ${dob}  ${phone2}  ${EMPTY}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${c5}  ${resp.json()}
    Log   ${resp.json()}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${phone2}${\n}
    ${f_name}=   FakerLibrary.first_name
    ${l_name}=   FakerLibrary.last_name
    ${dob}=      FakerLibrary.date
    ${phone}=    FakerLibrary.Random Int    min=1000000000   max=9999999999
    Set Suite Variable   ${phone}
    ${resp}=  AddCustomer without email  ${f_name}  ${l_name}  ${EMPTY}  ${Genderlist[1]}  ${dob}   ${phone}  ${EMPTY}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${c6}  ${resp.json()}
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${phone}${\n}
    ${resp}=  DeleteCustomer  ${c6}  
    Should Be Equal As Strings  ${resp.status_code}  200

    Log   ${resp.json()}
    ${f_name}=   FakerLibrary.first_name
    ${l_name}=   FakerLibrary.last_name
    ${dob}=      FakerLibrary.date
    ${phone}=    FakerLibrary.Random Int    min=1000000000   max=9999999999
    Set Suite Variable   ${phone}
    ${resp}=  AddCustomer without email  ${f_name}  ${l_name}  ${EMPTY}  ${Genderlist[1]}  ${dob}  ${phone}  ${EMPTY}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${c7}  ${resp.json()}
    Log   ${resp.json()} 
    Append To File  ${EXECDIR}/TDD/numbers.txt  ${phone}${\n}
    ${resp}=  GetCustomer    phoneNo-eq=${phone}    
    Log  ${resp.json()}
    Set Suite Variable     ${jid1}  ${resp.json()[0]['jaldeeId']}
    Log   ${resp.json()[0]['jaldeeId']}
    # ${resp}=  Get consumercount   status-eq=ACTIVE  
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable     ${Counts}     ${resp.json()}

JD-TC-Get Customer count-2
    [Documentation]  count customer by status

    ${resp}=  ProviderLogin  ${PUSERNAME77}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumercount   status-eq=ACTIVE  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()}  ${Counts}
    
JD-TC-Get Customer count-3
    [Documentation]  count customer consumer by account

    ${resp}=  ProviderLogin  ${PUSERNAME77}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumercount   account-eq=${c2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()}  7    
    

JD-TC-Get Customer count-4
    [Documentation]  count customer consumer  by Phone number

    ${resp}=  ProviderLogin  ${PUSERNAME77}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumercount  phoneNo-eq=${phone2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()}  1

JD-TC-Get Customer count-5
    [Documentation]  count customer consumer by email id

    ${resp}=  ProviderLogin  ${PUSERNAME77}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumercount  email-eq=${email}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()}  1
    
    
   
JD-TC-Get Customer count-6
    [Documentation]  count customer consumer by phone number 

    ${resp}=  ProviderLogin  ${PUSERNAME77}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumercount   phoneNo-eq=${phone3}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()}  1
    
JD-TC-Get Customer count-7
    [Documentation]  count customer by Genderlist

    ${resp}=  ProviderLogin  ${PUSERNAME77}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumercount    gender-eq=${Genderlist[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
   
JD-TC-Get Customer count-8
    [Documentation]  count customer   by name  and email

    ${resp}=  ProviderLogin  ${PUSERNAME77}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumercount     firstName-eq=${f_name1}  email-eq=${email}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()}  1
    
JD-TC-Get Customer count-9
    [Documentation]  count customer consumer  by dob

    ${resp}=  ProviderLogin  ${PUSERNAME77}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumercount   dob-eq=${dob}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()}  1
    
    
JD-TC-Get Customer count-10
    [Documentation]  count customer consumer by lastname

    ${resp}=  ProviderLogin  ${PUSERNAME77}  ${PASSWORD}    
    ${resp}=  Get consumercount   lastName-eq=${l_name1}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()}  2

JD-TC-Get Customer count-11
    [Documentation]  count addcustomer customer by jaldeeid

    ${resp}=  ProviderLogin  ${PUSERNAME77}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumercount   jaldeeId-eq=${jid1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()}  1


JD-TC-Get Customer count-12
    [Documentation]  count addcustomer customer by without input 

    ${resp}=  ProviderLogin  ${PUSERNAME77}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumercount  phoneNo-eq=${phone}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()}  1

JD-TC-Get Customer count-13
    [Documentation]  count customer by status

    ${resp}=  ProviderLogin  ${PUSERNAME77}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumercount   status-eq=INACTIVE 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()}  1


JD-TC-Get Customer count-UH1
    [Documentation]  count customer with out login 

    ${resp}=  Get consumercount  
    Should Be Equal As Strings  ${resp.status_code}  419  
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"  
     
JD-TC-Get Customer count-UH2
    [Documentation]  consumer try to use Addcustomer consumer count

    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200  
    ${resp}=  Get consumercount
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"     
