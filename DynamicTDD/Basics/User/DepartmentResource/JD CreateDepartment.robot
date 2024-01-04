*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Deparment
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/musers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***
${SERVICE1}	   Bridal Makeup_001
${SERVICE2}	   Groom MakeupW_002
${SERVICE3}	   Groom MakeupW_003
${SERVICE4}	   Groom MakeupW_004
${SERVICE5}	   Groom MakeupW_006
${SERVICE6}	   Groom MakeupW_007
${SERVICE7}	   Groom MakeupW_008
${SERVICE8}	   Groom MakeupW_009
${SERVICE9}	   Groom MakeupW_010
${SERVICE10}	   Groom MakeupW_011
${SERVICE11}	   Groom MakeupW_012
${SERVICE789}	   Groom MakeupW_789
${default_ser_durtn}   10  
${start}           30
${description}  Service
${defalut_value}  default

*** Test Cases ***
JD-TC-Create Department-1
    [Documentation]  Provider Create Department using service id

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    ${firstname_A}=  FakerLibrary.first_name
    Set Suite Variable  ${firstname_A}
    ${lastname_A}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname_A}
    ${MUSERNAME_H}=  Evaluate  ${MUSERNAME}+423815
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_H}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${MUSERNAME_H}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${MUSERNAME_H}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_H}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${MUSERNAME_H}${\n}
    Set Suite Variable  ${MUSERNAME_H}
    ${id}=  get_id  ${MUSERNAME_H}
    Set Suite Variable  ${id}
    
    ${ser_desc}=   FakerLibrary.word
    Set Suite Variable   ${ser_desc}
    ${total_amount}=    Random Int  min=100  max=500
    Set Suite Variable  ${total_amount}
    ${min_prepayment}=  Random Int   min=1   max=50
    Set Suite Variable   ${min_prepayment}
    ${ser_duratn}=      Random Int   min=10   max=30
    Set Suite Variable   ${ser_duratn}
    ${resp}=   Create Service  ${SERVICE1}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${min_prepayment}  ${total_amount}  ${bool[1]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid1}  ${resp.json()}  
    ${resp}=   Create Service  ${SERVICE2}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${min_prepayment}  ${total_amount}  ${bool[1]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid2}  ${resp.json()}  
    ${resp}=   Create Service  ${SERVICE3}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${min_prepayment}  ${total_amount}  ${bool[1]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid3}  ${resp.json()}  
    ${resp}=   Create Service  ${SERVICE5}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${min_prepayment}  ${total_amount}  ${bool[1]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid5}  ${resp.json()} 
    ${resp}=  Toggle Department Enable
    Should Be Equal As Strings  ${resp.status_code}  200
    ${dep_name1}=  FakerLibrary.bs
    Set Suite Variable   ${dep_name1}
    ${dep_code1}=   Random Int  min=100   max=999
    Set Suite Variable   ${dep_code1}
    ${dep_desc1}=   FakerLibrary.word  
    Set Suite Variable    ${dep_desc1}
    Log  ${dep_code1} 
    ${resp}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1}   ${sid1}  ${sid2}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${depid1}  ${resp.json()}

JD-TC-Create Department-2
    [Documentation]  Provider Create department using Service names

    ${resp}=  Encrypted Provider Login  ${MUSERNAME24}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${dep_name2}=  FakerLibrary.bs
    Set Suite Variable   ${dep_name2}
    ${dep_code2}=   Random Int  min=100   max=999
    Set Suite Variable   ${dep_code2}
    ${resp}=  Toggle Department Enable
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Create Department With ServiceName  ${dep_name2}  ${dep_code2}  ${dep_desc1}    ${SERVICE3}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${depid2}  ${resp.json()}


JD-TC-Create Department-3
    [Documentation]  Provider Create department without service details[Empty department]

    ${resp}=  Encrypted Provider Login  ${MUSERNAME25}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${dep_name3}=  FakerLibrary.bs
    Set Suite Variable   ${dep_name3}
    ${dep_code3}=   Random Int  min=100   max=999
    Set Suite Variable   ${dep_code3}
    ${resp}=  Toggle Department Enable
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Create Department  ${dep_name3}  ${dep_code3}  ${dep_desc1}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${depid3}  ${resp.json()}

JD-TC-Create Department-4
    [Documentation]  Provider Create department with same name as another providers dep. name

    ${resp}=  Encrypted Provider Login  ${MUSERNAME26}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Toggle Department Enable
    Should Be Equal As Strings  ${resp.status_code}  200
    ${dep_code4}=   Random Int  min=100   max=999
    Set Suite Variable   ${dep_code4}
    ${resp}=  Create Department  ${dep_name3}  ${dep_code4}  ${dep_desc1}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${depid4}  ${resp.json()}


JD-TC-Create Department-UH1
    [Documentation]  Provider Create already existing department name

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_H}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200    
    ${resp}=  Create Department With ServiceName  ${dep_name1}  ${dep_code2}  ${dep_desc1}    ${SERVICE4} 
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${DETP_ALREADY_EXISTS}"

JD-TC-Create Department-UH2
    [Documentation]  Provider Create already existing department code
    
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_H}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${dep_name4}=  FakerLibrary.bs
    Log  ${dep_code1} 
    ${resp}=  Create Department With ServiceName  ${dep_name4}  ${dep_code1}  ${dep_desc1}    ${SERVICE4} 
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${DETP_CODE_ALREADY_EXISTS}"

JD-TC-Create Department-UH3
    [Documentation]  Provider Create a department with new service name

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_H}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${ser_name}=   FakerLibrary.word
    ${dep_name}=  FakerLibrary.bs
    ${dep_code}=   Random Int  min=100   max=999
    ${resp}=  Create Department With ServiceName  ${dep_name}  ${dep_code}  ${dep_desc1}   ${ser_name}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${depid6}  ${resp.json()}
    ${resp}=  Get Department ById  ${depid6}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  departmentName=${dep_name}  departmentId=${depid6}  departmentCode=${dep_code}  departmentDescription=${dep_desc1}  departmentStatus=${status[0]}
    ${count}=  Get Length  ${resp.json()['serviceIds']} 
	Should Be Equal As Integers  ${count}  1
    ${resp}=   Get Service
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200 
    ${count}=  Get Length  ${resp.json()} 
	#Should Be Equal As Integers  ${count}  7
	Verify Response List  ${resp}  0  name=${ser_name}  description=${ser_name} ${description}  serviceDuration=${default_ser_durtn}  notificationType=${notifytype[0]}   totalAmount=0.0  status=${status[0]}    isPrePayment=${bool[0]}
    # Verify Response List  ${resp}  1  name=${SERVICE3}  description=${SERVICE3} ${description}  serviceDuration=${default_ser_durtn}  notificationType=${notifytype[0]}   totalAmount=0.0  status=${status[0]}    isPrePayment=${bool[0]}
    # Verify Response List  ${resp}  2  name=${SERVICE5}  description=${ser_desc}                 serviceDuration=${ser_duratn}         notificationType=${notifytype[2]}   minPrePaymentAmount=${min_prepayment}.0  totalAmount=${total_amount}.0  bType=${btype}  status=${status[0]}  isPrePayment=${bool[1]} 
    # Verify Response List  ${resp}  3  name=${SERVICE3}  description=${ser_desc}                 serviceDuration=${ser_duratn}         notificationType=${notifytype[2]}   minPrePaymentAmount=${min_prepayment}.0  totalAmount=${total_amount}.0  bType=${btype}  status=${status[0]}  isPrePayment=${bool[1]} 
    # Verify Response List  ${resp}  4  name=${SERVICE2}  description=${ser_desc}                 serviceDuration=${ser_duratn}         notificationType=${notifytype[2]}   minPrePaymentAmount=${min_prepayment}.0  totalAmount=${total_amount}.0  bType=${btype}  status=${status[0]}  isPrePayment=${bool[1]}
    # Verify Response List  ${resp}  5  name=${SERVICE1}  description=${ser_desc}                 serviceDuration=${ser_duratn}         notificationType=${notifytype[2]}   minPrePaymentAmount=${min_prepayment}.0  totalAmount=${total_amount}.0  bType=${btype}  status=${status[0]}  isPrePayment=${bool[1]} 

JD-TC-Create Department-UH4
    [Documentation]  Provider Create a department with another provider's service id

    ${resp}=  Encrypted Provider Login  ${MUSERNAME27}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
  
    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    
    ${dep_name}=  FakerLibrary.bs
    ${dep_code}=   Random Int  min=100   max=999
    ${resp}=  Create Department  ${dep_name}  ${dep_code}  ${dep_desc1}    ${sid1}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${SERVICE_NOT_EXISTS}"

JD-TC-Create Department-UH5
     [Documentation]  Create a department without login
     
     ${dep_name}=  FakerLibrary.bs
     ${dep_code}=   Random Int  min=100   max=999
     ${resp}=  Create Department  ${dep_name}  ${dep_code}  ${dep_desc1}    ${sid1}
     Should Be Equal As Strings  ${resp.status_code}  419
     Should Be Equal As Strings   "${resp.json()}"    "${SESSION_EXPIRED}"
     
JD-TC-Create Department-UH6
     [Documentation]  Create a department using consumer login

     ${resp}=  ConsumerLogin  ${CUSERNAME0}  ${PASSWORD}
     Should Be Equal As Strings  ${resp.status_code}  200
     ${dep_name}=  FakerLibrary.bs
     ${dep_code}=   Random Int  min=100   max=999
     ${resp}=  Create Department  ${dep_name}  ${dep_code}  ${dep_desc1}    ${sid1}
     Should Be Equal As Strings  ${resp.status_code}  401
     Should Be Equal As Strings   "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-Create Department-UH7
    [Documentation]  Provider Create a department with Invalid service id

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_H}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${dep_name}=  FakerLibrary.bs
    ${dep_code}=   Random Int  min=100   max=999
    ${invalid_ser_id}=  Random Int  min=-499  max=-1
    ${resp}=  Create Department  ${dep_name}  ${dep_code}  ${dep_desc1}    ${invalid_ser_id}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${SERVICE_NOT_EXISTS}"

JD-TC-Create Department-UH8
    [Documentation]  Provider Create department without Department name

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_H}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${dep_code}=   Random Int  min=100   max=999
    ${resp}=  Create Department  ${Empty}  ${dep_code}  ${dep_desc1} 
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${DETP_NAME_NOT_GIVEN}"

JD-TC-Create Department-UH9
    [Documentation]  Provider Create department without Department code

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_H}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${dep_name}=  FakerLibrary.bs
    ${resp}=  Create Department  ${dep_name}  ${Empty}  ${dep_desc1} 
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${DETP_CODE_NOT_GIVEN}"

JD-TC-Create Department-UH10
    [Documentation]  Provider adding disabled service to department

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_H}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Disable service  ${sid5} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Add Services To Department  ${depid6}  ${sid5}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${SERVICE5} ${SERVICE_NOT_ENABLED}"

JD-TC-Create Department-5
    [Documentation]  Checking for all domains
    Comment  Provider Create department using Service names

    ${resp}=  Encrypted Provider Login  ${MUSERNAME27}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Create Department With ServiceName  ${dep_name2}  ${dep_code2}  ${dep_desc1}   ${SERVICE6}  ${SERVICE7}  ${SERVICE8}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${depidL1}  ${resp.json()}
    
JD-TC-Create Department-6
    [Documentation]  Provider Create department using Service names

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    ${firstname_A}=  FakerLibrary.first_name
    Set Suite Variable  ${firstname_A}
    ${lastname_A}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname_A}
    ${MUSERNAME_I}=  Evaluate  ${MUSERNAME}+423816
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_I}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${MUSERNAME_I}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${MUSERNAME_I}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_I}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${MUSERNAME_I}${\n}
    Set Suite Variable  ${MUSERNAME_I}
    ${id}=  get_id  ${MUSERNAME_I}
    Set Suite Variable  ${id}
    
    ${resp}=   Create Service  ${SERVICE1}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${min_prepayment}  ${total_amount}  ${bool[1]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid11}  ${resp.json()}  
    ${resp}=   Create Service  ${SERVICE2}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${min_prepayment}  ${total_amount}  ${bool[1]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid21}  ${resp.json()}  
    ${resp}=   Create Service  ${SERVICE3}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${min_prepayment}  ${total_amount}  ${bool[1]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid31}  ${resp.json()}  
    ${resp}=  Toggle Department Enable
    Should Be Equal As Strings  ${resp.status_code}  200
    ${dep_name}=  FakerLibrary.bs
    Set Suite Variable  ${dep_name}
    ${dep_code}=   Random Int  min=100   max=999
    Set Suite Variable   ${dep_code}
    ${resp}=  Create Department With ServiceName  ${dep_name}  ${dep_code}  ${dep_desc1}    ${SERVICE9}  ${SERVICE10}  ${SERVICE11}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${depid012}  ${resp.json()}

JD-TC-Create Department-7
    [Documentation]  Provider Create department using Service names

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_H}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${SERVICE1}=	   FakerLibrary.Word
    ${SERVICE2}=	   FakerLibrary.Word
    ${SERVICE3}=	   FakerLibrary.Word
    ${resp}=  Create Department With ServiceName  ${dep_name2}  ${dep_code2}  ${dep_desc1}   ${SERVICE1}  ${SERVICE2}  ${SERVICE3}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${depidM1}  ${resp.json()}

JD-TC-Create Department-8
    [Documentation]  Provider Create department using Service names

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    Set Suite Variable  ${sub_domain_id}   ${iscorp_subdomains[0]['subdomainId']}
    ${firstname_A}=  FakerLibrary.first_name
    Set Suite Variable  ${firstname_A}
    ${lastname_A}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname_A}
    ${MUSERNAME_J}=  Evaluate  ${MUSERNAME}+423817
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_J}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${MUSERNAME_J}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${MUSERNAME_J}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_J}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${MUSERNAME_J}${\n}
    Set Suite Variable  ${MUSERNAME_J}
    ${id}=  get_id  ${MUSERNAME_J}
    Set Suite Variable  ${id}
    
    
    ${resp}=   Create Service  ${SERVICE1}  ${ser_desc}  ${ser_duratn}  ${status[0]}  ${bType}  ${bool[1]}  ${notifytype[2]}  ${min_prepayment}  ${total_amount}  ${bool[1]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid1_6}  ${resp.json()}
    ${resp}=  Toggle Department Enable
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${SERVICE1}=	   FakerLibrary.Word
    ${SERVICE2}=	   FakerLibrary.Word
    ${SERVICE3}=	   FakerLibrary.Word
    ${resp}=  Create Department With ServiceName  ${dep_name2}  ${dep_code2}  ${dep_desc1}  ${SERVICE1}  ${SERVICE2}  ${SERVICE3}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${depidJ1}  ${resp.json()}

JD-TC-Create Department-9
    [Documentation]  Provider Create department using same Service names and ids

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_J}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${dep_name11}=  FakerLibrary.bs
    Set Suite Variable   ${dep_name11}
    ${dep_code11}=   Random Int  min=100   max=999
    Set Suite Variable   ${dep_code11}
    ${resp}=  Create Department  ${dep_name11}  ${dep_code11}  ${dep_desc1}   ${sid1_6}  ${sid1_6}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${depidJ2}  ${resp.json()}
    ${dep_name12}=  FakerLibrary.bs
    Set Suite Variable   ${dep_name12}
    ${dep_code12}=   Random Int  min=100   max=999
    Set Suite Variable   ${dep_code12}
    ${SERVICE1}=	   FakerLibrary.Word
    ${resp}=  Create Department With ServiceName  ${dep_name12}  ${dep_code12}  ${dep_desc1}  ${SERVICE1}  ${SERVICE1}  ${SERVICE1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${depidJ3}  ${resp.json()}

JD-TC-Create Department-10
    [Documentation]  Provider Create department 

    ${resp}=  Encrypted Provider Login  ${MUSERNAME32}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
   
    clear_service   ${MUSERNAME32}

    # ${resp}=  Toggle Department Disable
    # Log   ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    
    # ${resp}=  Toggle Department Enable
    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    ${dep_name}=  FakerLibrary.bs
    ${dep_code}=   Random Int  min=100   max=999
    ${resp}=  Create Department  ${dep_name}  ${dep_code}  ${dep_desc1}   
    Set Test Variable  ${depid456}  ${resp.json()}
    ${resp}=  Create Service Department  ${SERVICE789}  ${dep_desc1}   ${ser_duratn}   ${bType}  ${bool[1]}  ${notifytype[2]}  ${min_prepayment}  ${total_amount}  ${bool[1]}  ${bool[0]}  ${depid456}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid456}  ${resp.json()}
    ${dep_name}=  FakerLibrary.bs
    ${dep_code}=   Random Int  min=100   max=999
    ${resp}=  Create Department  ${dep_name}  ${dep_code}  ${dep_desc1}   
    Set Test Variable  ${depid789}  ${resp.json()}
    ${SERVICE790}=	   FakerLibrary.Word
    ${resp}=  Create Service Department  ${SERVICE790}  ${dep_desc1}   ${ser_duratn}    ${bType}  ${bool[1]}  ${notifytype[2]}  ${min_prepayment}  ${total_amount}  ${bool[1]}  ${bool[0]}  ${depid789}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid789}  ${resp.json()}
    ${resp}=  Get Departments 
    Log   ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Toggle Department Disable
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Departments
    Log   ${resp.json()}  
    ${resp}=  Toggle Department Enable
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    sleep   2s
JD-TC-Verify Create Department-1
    [Documentation]  Verify Provider Create Department using service id

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_H}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Department ById  ${depid1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  departmentName=${dep_name1}  departmentId=${depid1}  departmentCode=${dep_code1}  departmentDescription=${dep_desc1}  departmentStatus=${status[0]}
    Should Be Equal As Strings  ${resp.json()['serviceIds'][0]}  ${sid1}
    Should Be Equal As Strings  ${resp.json()['serviceIds'][1]}  ${sid2}

JD-TC-Verify Create Department-2
    [Documentation]  Verify Provider Create department using Service names

    ${resp}=  Encrypted Provider Login  ${MUSERNAME24}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200  
    ${resp}=  Get Department ById  ${depid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  departmentName=${dep_name2}  departmentId=${depid2}  departmentCode=${dep_code2}  departmentDescription=${dep_desc1}  departmentStatus=${status[0]}
    ${count}=  Get Length  ${resp.json()['serviceIds']} 
    Should Be Equal As Integers  ${count}  1

JD-TC-Verify Create Department-3
    [Documentation]  Verify Provider Create department without service details[Empty department]

    ${resp}=  Encrypted Provider Login  ${MUSERNAME25}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Department ById  ${depid3}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  departmentName=${dep_name3}  departmentId=${depid3}  departmentCode=${dep_code3}  departmentDescription=${dep_desc1}  departmentStatus=${status[0]}
    Should Be Equal As Strings  ${resp.json()['serviceIds']}  []

JD-TC-Verify Create Department-5
    [Documentation]  Verify  Checking for all domains
    Comment  Provider Create department using Service names

    ${resp}=  Encrypted Provider Login  ${MUSERNAME27}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Department ById  ${depidL1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  departmentName=${dep_name2}  departmentId=${depidL1}  departmentCode=${dep_code2}  departmentDescription=${dep_desc1}  departmentStatus=${status[0]}
    ${count}=  Get Length  ${resp.json()['serviceIds']} 
    Should Be Equal As Integers  ${count}  3

JD-TC-Verify Create Department-6
    [Documentation]  Verify Provider Create department using Service names

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_I}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get Department ById  ${depid012}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  departmentName=${dep_name}  departmentId=${depid012}  departmentCode=${dep_code}  departmentDescription=${dep_desc1}  departmentStatus=${status[0]}
    ${count}=  Get Length  ${resp.json()['serviceIds']} 
    Log  ${resp.json()}
    Should Be Equal As Integers  ${count}  3

JD-TC-Verify Create Department-7
    [Documentation]  Verify Provider Create department using Service names

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_H}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200   
    ${resp}=  Get Department ById  ${depidM1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  departmentName=${dep_name2}  departmentId=${depidM1}  departmentCode=${dep_code2}  departmentDescription=${dep_desc1}  departmentStatus=${status[0]}
    ${count}=  Get Length  ${resp.json()['serviceIds']} 
    Should Be Equal As Integers  ${count}  3

JD-TC-Verify Create Department-8
    [Documentation]  Verify Provider Create department using Service names

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_J}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get Department ById  ${depidJ1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  departmentName=${dep_name2}  departmentId=${depidJ1}  departmentCode=${dep_code2}  departmentDescription=${dep_desc1}  departmentStatus=${status[0]}
    ${count}=  Get Length  ${resp.json()['serviceIds']} 
    Should Be Equal As Integers  ${count}  3

JD-TC-Verify Create Department-9
    [Documentation]  Verify Provider Create department using same Service names and ids

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_J}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200 
    sleep   2s  
    ${resp}=  Get Department ById  ${depidJ2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['serviceIds'][0]}  ${sid1_6}
    ${count}=  Get Length  ${resp.json()['serviceIds']} 
    Should Be Equal As Integers  ${count}  1
    ${resp}=  Get Department ById  ${depidJ3}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${count}=  Get Length  ${resp.json()['serviceIds']} 
    Should Be Equal As Integers  ${count}  1

*** comments ***
JD-TC-Verify Create Department-10
    [Documentation]  Verify Provider Create department 

    ${resp}=  Encrypted Provider Login  ${MUSERNAME32}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Get Departments 
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.json()['departments'][2]['departmentName']}              ${defalut_value}
    Should Be Equal As Strings  ${resp.json()['departments'][2]['departmentCode']}              ${defalut_value}
    Should Be Equal As Strings  ${resp.json()['departments'][2]['departmentDescription']}       ${defalut_value}
    Should Be Equal As Strings  ${resp.json()['departments'][2]['departmentStatus']}            ${status[0]}
    Should Be Equal As Strings  ${resp.json()['departments'][2]['serviceIds'][0]}               ${sid456}
    Should Be Equal As Strings  ${resp.json()['departments'][2]['serviceIds'][1]}               ${sid789}

