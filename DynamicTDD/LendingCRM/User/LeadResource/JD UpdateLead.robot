*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Lead
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/musers.py

*** Variables ***

@{emptylist} 



*** Test Cases ***

JD-TC-UpdateLead-1

    [Documentation]   Create Lead to a branch and then update the lead.

    ${iscorp_subdomains}=  get_iscorp_subdomains  1
    Log  ${iscorp_subdomains}
    Set Suite Variable  ${domains}  ${iscorp_subdomains[0]['domain']}
    Set Suite Variable  ${sub_domains}   ${iscorp_subdomains[0]['subdomains']}
    ${firstname_A}=  FakerLibrary.first_name
    Set Suite Variable  ${firstname_A}
    ${lastname_A}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname_A}
    ${MUSERNAME_E}=  Evaluate  ${MUSERNAME}+550601
    ${highest_package}=  get_highest_license_pkg
    ${resp}=  Account SignUp  ${firstname_A}  ${lastname_A}  ${None}  ${domains}  ${sub_domains}  ${MUSERNAME_E}    ${highest_package[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${MUSERNAME_E}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${MUSERNAME_E}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${id}  ${decrypted_data['id']}
    
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${MUSERNAME_E}${\n}
    Append To File  ${EXECDIR}/TDD/TDD_Logs/providernumbers.txt  ${SUITE NAME} - ${TEST NAME} - ${MUSERNAME_E}${\n}
    Set Suite Variable  ${MUSERNAME_E}

    ${p_id}=  get_acc_id  ${MUSERNAME_E}

    ${resp}=   enquiryStatus  ${p_id}
    ${resp}=   leadStatus     ${p_id}
    ${resp}=   categorytype   ${p_id}
    ${resp}=   tasktype       ${p_id}

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${lid}=  Create Sample Location
        Set Suite Variable  ${lid}

        ${resp}=   Get Location ById  ${lid}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Suite Variable  ${lidname}  ${resp.json()['place']}
        
    ELSE
        Set Suite Variable  ${lid}  ${resp.json()[0]['id']}
        Set Suite Variable  ${lidname}  ${resp.json()[0]['place']}
    END

    ${lid2}=  Create Sample Location
    Set Suite Variable  ${lid2}

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
    ${PUSERNAME_U1}=  Evaluate  ${PUSERNAME}+336675
    clear_users  ${PUSERNAME_U1}
    Set Suite Variable  ${PUSERNAME_U1}
    ${firstname}=  FakerLibrary.name
    Set Suite Variable  ${firstname}
    ${lastname}=  FakerLibrary.last_name
    Set Suite Variable  ${lastname}
    ${dob}=  FakerLibrary.Date
    Set Suite Variable  ${dob}
     FOR    ${i}    IN RANGE    3
        ${pin}=  get_pincode
        ${kwstatus}  ${resp} =  Run Keyword And Ignore Error  Get LocationsByPincode  ${pin}
        IF    '${kwstatus}' == 'FAIL'
                Continue For Loop
        ELSE IF    '${kwstatus}' == 'PASS'
                Exit For Loop
        END
     END
     Should Be Equal As Strings    ${resp.status_code}    200 
     Set Suite Variable  ${pin}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${city}   ${resp.json()[0]['PostOffice'][0]['District']}   
    Set Suite Variable  ${state}  ${resp.json()[0]['PostOffice'][0]['State']}      
    Set Suite Variable  ${pin}    ${resp.json()[0]['PostOffice'][0]['Pincode']}    

    ${whpnum}=  Evaluate  ${PUSERNAME}+346251
    ${tlgnum}=  Evaluate  ${PUSERNAME}+346351

    ${resp}=  Create User  ${firstname}  ${lastname}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U1}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U1}  ${dep_id}  ${EMPTY}  ${bool[0]}  ${countryCodes[1]}  ${whpnum}  ${countryCodes[1]}  ${tlgnum}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SendProviderResetMail   ${PUSERNAME_U1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERNAME_U1}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${PUSERNAME_U2}=  Evaluate  ${PUSERNAME}+3466470
    clear_users  ${PUSERNAME_U2}
    Set Suite Variable  ${PUSERNAME_U2}
    clear_users  ${PUSERNAME_U2}
    Set Suite Variable  ${PUSERNAME_U2}
    ${firstname1}=  FakerLibrary.name
    Set Suite Variable  ${firstname}
    ${lastname1}=  FakerLibrary.last_name
    
  
    
    ${whpnum}=  Evaluate  ${PUSERNAME}+346869
    ${tlgnum}=  Evaluate  ${PUSERNAME}+346393

    ${resp}=  Create User  ${firstname1}  ${lastname1}  ${dob}  ${Genderlist[0]}  ${P_Email}${PUSERNAME_U2}.${test_mail}   ${userType[0]}  ${pin}  ${countryCodes[1]}  ${PUSERNAME_U2}  ${dep_id}  ${EMPTY}  ${bool[0]}  ${countryCodes[1]}  ${whpnum}  ${countryCodes[1]}  ${tlgnum}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${u_id1}  ${resp.json()}

    ${resp}=  Get User By Id  ${u_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  SendProviderResetMail   ${PUSERNAME_U2}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${PUSERNAME_U2}  ${PASSWORD}  2
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${MUSERNAME_E}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${locId}=  Create Sample Location
    Set Suite Variable  ${locId}

    ${title}=  FakerLibrary.user name
    ${desc}=   FakerLibrary.word 
    ${targetPotential}=    FakerLibrary.Building Number
    Set Suite Variable  ${targetPotential}
    ${resp}=  AddCustomer  ${CUSERNAME3}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME3}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable  ${pcons_id3}  ${resp.json()[0]['id']}
    Set Test Variable  ${jaldeeId}  ${resp.json()[0]['jaldeeId']}

    ${resp}=    Create Lead    ${title}    ${desc}    ${targetPotential}      ${locId}    ${pcons_id3}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${leid}        ${resp.json()['id']}
    Set Suite Variable   ${leUid}        ${resp.json()['uid']}
    
    ${p_id1}=  get_acc_id  ${MUSERNAME_E}
    Set Suite Variable    ${p_id1}

    ${resp}=  categorytype  ${p_id1}
    ${resp}=  tasktype      ${p_id1}
    ${resp}=    Get Lead Category Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${Category_id}    ${resp.json()[1]['id']}
    Set Suite Variable  ${Category_id1}    ${resp.json()[1]['id']}
    Set Suite Variable  ${Category_id2}    ${resp.json()[2]['id']}
    # Set Suite Variable  ${priority_id3}    ${resp.json()[3]['id']}
    Set Suite Variable  ${category_name2}  ${resp.json()[0]['name']}

    ${resp}=    Get Lead Type
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${type_id2}    ${resp.json()[0]['id']}
    Set Suite Variable  ${type_name2}  ${resp.json()[0]['name']}
    ${resp}=  categorytype  ${p_id1}
    ${resp}=  tasktype      ${p_id1}
    ${resp}=    Get Lead Status
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${status_id}    ${resp.json()[0]['id']}
    Set Suite Variable  ${status_id1}    ${resp.json()[1]['id']}
    Set Suite Variable  ${status_id2}    ${resp.json()[2]['id']}
    Set Suite Variable  ${status_id3}    ${resp.json()[3]['id']}
    Set Suite Variable  ${status_id4}    ${resp.json()[4]['id']}
    Set Suite Variable  ${status_id5}    ${resp.json()[5]['id']}
    Set Suite Variable  ${status_name2}  ${resp.json()[0]['name']}

    ${resp}=    Get Lead Priority
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${priority_id}    ${resp.json()[0]['id']}
    Set Suite Variable  ${priority_id1}    ${resp.json()[1]['id']}
    Set Suite Variable  ${priority_id2}    ${resp.json()[2]['id']}
    Set Suite Variable  ${priority_id3}    ${resp.json()[3]['id']}
    Set Suite Variable  ${priority_name2}  ${resp.json()[0]['name']}

    ${title1}=  FakerLibrary.user name
    Set Suite Variable    ${title1}
    ${title2}=  FakerLibrary.user name
    Set Suite Variable    ${title2}
    ${desc1}=   FakerLibrary.word 
    Set Suite Variable    ${desc1}
    ${desc2}=   FakerLibrary.word 
    Set Suite Variable    ${desc2}
    ${targetPotential1}=    FakerLibrary.Building Number
    Set Suite Variable    ${targetPotential1}
    
    ${resp}=    Update Lead    ${leUid}    ${title1}    ${desc1}    ${status_id1}      ${priority_id}    ${lid2}    ${pcons_id3}    ${id}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Leads With Filter   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['uid']}    ${leUid}
    Should Be Equal As Strings  ${resp.json()[0]['title']}    ${title1}
    Should Be Equal As Strings  ${resp.json()[0]['description']}    ${desc1}
    Should Be Equal As Strings  ${resp.json()[0]['status']['id']}    ${status_id1}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['id']}    ${priority_id}
    # Should Be Equal As Strings  ${resp.json()[0]['location']['id']}    ${lid2}
    Should Be Equal As Strings  ${resp.json()[0]['customer']['id']}    ${pcons_id3}
    Should Be Equal As Strings  ${resp.json()[0]['assignee']['id']}    ${id}

JD-TC-UpdateLead-2

    [Documentation]   Create multiple Lead to a user and then update the lead.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Create Lead    ${title1}    ${desc1}    ${targetPotential}      ${lid}    ${pcons_id3}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${leid1}        ${resp.json()['id']}
    Set Suite Variable   ${leUid1}        ${resp.json()['uid']}

    ${resp}=    Create Lead    ${title2}    ${desc2}    ${targetPotential}      ${lid}    ${pcons_id3}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${leid2}        ${resp.json()['id']}
    Set Suite Variable   ${leUid2}        ${resp.json()['uid']}

    ${resp}=    Update Lead    ${leUid1}    ${title1}    ${desc1}    ${status_id1}      ${priority_id}    ${locId}    ${pcons_id3}    ${u_id}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Update Lead    ${leUid2}    ${title1}    ${desc1}    ${status_id1}      ${priority_id}    ${locId}    ${pcons_id3}    ${u_id}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Leads With Filter   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[1]['uid']}    ${leUid1}
    Should Be Equal As Strings  ${resp.json()[1]['title']}    ${title1}
    Should Be Equal As Strings  ${resp.json()[1]['description']}    ${desc1}
    Should Be Equal As Strings  ${resp.json()[1]['status']['id']}    ${status_id1}
    Should Be Equal As Strings  ${resp.json()[1]['priority']['id']}    ${priority_id}
    # Should Be Equal As Strings  ${resp.json()[1]['location']['id']}    ${locId}
    Should Be Equal As Strings  ${resp.json()[1]['customer']['id']}    ${pcons_id3}
    Should Be Equal As Strings  ${resp.json()[1]['assignee']['id']}    ${u_id}

    Should Be Equal As Strings  ${resp.json()[0]['uid']}    ${leUid2}
    Should Be Equal As Strings  ${resp.json()[0]['title']}    ${title1}
    Should Be Equal As Strings  ${resp.json()[0]['description']}    ${desc1}
    Should Be Equal As Strings  ${resp.json()[0]['status']['id']}    ${status_id1}
    Should Be Equal As Strings  ${resp.json()[0]['priority']['id']}    ${priority_id}
    # Should Be Equal As Strings  ${resp.json()[0]['location']['id']}    ${locId}
    Should Be Equal As Strings  ${resp.json()[0]['customer']['id']}    ${pcons_id3}
    Should Be Equal As Strings  ${resp.json()[0]['assignee']['id']}    ${u_id}

JD-TC-UpdateLead-3

    [Documentation]   update the lead with different title and verify it.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${title3}=  FakerLibrary.user name
    Set Suite Variable    ${title3}

    ${resp}=    Update Lead    ${leUid1}    ${title3}    ${desc1}    ${status_id1}      ${priority_id}    ${locId}    ${pcons_id3}    ${u_id}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Leads With Filter   uid-eq=${leUid1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['title']}    ${title3}
JD-TC-UpdateLead-4

    [Documentation]   update the lead with different status and verify it.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Lead    ${leUid1}    ${title3}    ${desc1}    ${status_id}      ${priority_id}    ${locId}    ${pcons_id3}    ${u_id}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Update Lead    ${leUid1}    ${title3}    ${desc1}    ${status_id2}      ${priority_id}    ${locId}    ${pcons_id3}    ${u_id}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Update Lead    ${leUid1}    ${title3}    ${desc1}    ${status_id3}      ${priority_id}    ${locId}    ${pcons_id3}    ${u_id}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Leads With Filter   uid-eq=${leUid1}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['status']['id']}    ${status_id3}


JD-TC-UpdateLead-5

    [Documentation]   update the lead with different priority and verify it.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Lead    ${leUid1}    ${title3}    ${desc1}    ${status_id3}      ${priority_id1}    ${locId}    ${pcons_id3}    ${u_id}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Update Lead    ${leUid1}    ${title3}    ${desc1}    ${status_id3}      ${priority_id2}    ${locId}    ${pcons_id3}    ${u_id}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Leads With Filter   priority-eq=${priority_id2}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['priority']['id']}    ${priority_id2}

JD-TC-UpdateLead-6

    [Documentation]   create a lead to a customer then update the lead to another customer.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  AddCustomer  ${CUSERNAME6}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME6}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable  ${pcons_id6}  ${resp.json()[0]['id']}
    Set Test Variable  ${jaldeeId}  ${resp.json()[0]['jaldeeId']}

    ${resp}=    Create Lead    ${title2}    ${desc2}    ${targetPotential}      ${lid}    ${pcons_id3}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${leid6}        ${resp.json()['id']}
    Set Suite Variable   ${leUid6}        ${resp.json()['uid']}

    ${resp}=    Update Lead    ${leUid1}    ${title3}    ${desc1}    ${status_id3}      ${priority_id2}    ${locId}    ${pcons_id6}    ${u_id}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Leads With Filter   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[2]['customer']['id']}    ${pcons_id6}

JD-TC-UpdateLead-7

    [Documentation]   create a lead without assignee then update the lead with assignee.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Create Lead    ${title1}    ${desc1}    ${targetPotential}      ${lid}    ${pcons_id3}   
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${leid2}        ${resp.json()['id']}
    Set Suite Variable   ${leUid2}        ${resp.json()['uid']}

    ${resp}=    Update Lead    ${leUid2}    ${title1}    ${desc1}    ${status_id}      ${priority_id2}    ${locId}    ${pcons_id3}    ${u_id1}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Leads With Filter   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['assignee']['id']}    ${u_id1}



JD-TC-UpdateLead-8

    [Documentation]   create a lead without manager then update the lead with manager.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=    Remove Lead Manager    ${leUid2}
    # Log   ${resp.content}
    # Should Be Equal As Strings  ${resp.status_code}  200

    ${manager}=    Create Dictionary    id=${id}

    ${resp}=    Update Lead    ${leUid2}    ${title1}    ${desc1}    ${status_id}      ${priority_id2}    ${locId}    ${pcons_id3}    ${u_id1}    manager=${manager}
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=    Get Leads With Filter   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()[0]['manager']['id']}    ${id}

JD-TC-UpdateLead-UH1

    [Documentation]  update a lead with invalid customer id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${pcons_id4}=    get_acc_id    ${CUSERNAME28}

    ${resp}=    Update Lead    ${leUid2}    ${title1}    ${desc1}    ${status_id}      ${priority_id2}    ${locId}    ${pcons_id4}    ${u_id1}   
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}    ${CONSUMER_REQUIRED}


JD-TC-UpdateLead-UH2

    [Documentation]  update a lead with invalid location id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${location}=    FakerLibrary.Building Number
    ${resp}=    Update Lead    ${leUid2}    ${title1}    ${desc1}    ${status_id}      ${priority_id2}    ${location}    ${pcons_id3}    ${u_id1}   
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}    ${INVALID_BUSS_LOC_ID}

JD-TC-UpdateLead-UH3

    [Documentation]  update a lead with another branch's location id.

    ${resp}=  Encrypted Provider Login  ${MUSERNAME31}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${Blid}=    Create Sample Location
    Set Suite Variable   ${Blid}

    ${resp}=  AddCustomer  ${CUSERNAME4}    
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME4}
    Log   ${resp.json()}
    Should Be Equal As Strings      ${resp.status_code}  200
    Set Suite Variable  ${pcons_id5}  ${resp.json()[0]['id']}
    Set Test Variable  ${jaldeeId}  ${resp.json()[0]['jaldeeId']}
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Lead    ${leUid2}    ${title1}    ${desc1}    ${status_id}      ${priority_id2}    ${Blid}    ${pcons_id3}    ${u_id1}   
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}    ${INVALID_BUSS_LOC_ID}

JD-TC-UpdateLead-UH4

    [Documentation]  update a lead with another branch's customer id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Lead    ${leUid2}    ${title1}    ${desc1}    ${status_id}      ${priority_id2}    ${lid}    ${pcons_id5}    ${u_id1}   
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}    ${INVALID_CONSUMER_ID}



JD-TC-UpdateLead-UH5

    [Documentation]  update a lead with jaldee consumer(not provider consumer).

    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${jdconID}   ${resp.json()['id']}
    Set Test Variable  ${fname}   ${resp.json()['firstName']}
    Set Test Variable  ${lname}   ${resp.json()['lastName']}

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Lead    ${leUid1}    ${title3}    ${desc1}    ${status_id3}      ${priority_id2}    ${locId}    ${jdconID}    ${u_id}  
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}    ${INVALID_CONSUMER_ID}

JD-TC-UpdateLead-UH6

    [Documentation]  update a lead with empty customer id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Lead    ${leUid2}    ${title1}    ${desc1}    ${status_id}      ${priority_id2}    ${locId}    ${EMPTY}    ${u_id1}    
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}    ${CONSUMER_REQUIRED}

JD-TC-UpdateLead-UH7

    [Documentation]  update a lead with empty location id.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Lead    ${leUid2}    ${title1}    ${desc1}    ${status_id}      ${priority_id2}    ${EMPTY}    ${pcons_id3}    ${u_id1}    
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}    ${LOCATION_REQUIRED}

JD-TC-UpdateLead-UH8

    [Documentation]  update a lead without status.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Lead    ${leUid2}    ${title1}    ${desc1}    ${EMPTY}      ${priority_id2}    ${locId}    ${pcons_id3}    ${u_id1}    
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}    ${STATUS_REQUIRED}

JD-TC-UpdateLead-UH9

    [Documentation]  update a lead without priority.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Lead    ${leUid2}    ${title1}    ${desc1}    ${status_id}      ${EMPTY}    ${locId}    ${pcons_id3}    ${u_id1}    
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}    ${PRIORITY_REQUIRED}

JD-TC-UpdateLead-UH10

    [Documentation]  update a lead without title.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=    Update Lead    ${leUid2}    ${EMPTY}    ${desc1}    ${status_id}      ${priority_id2}    ${locId}    ${pcons_id3}    ${u_id1}   
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}    ${TITLE_REQUIRED}


JD-TC-UpdateLead-UH11

    [Documentation]  update a lead without login.

    ${resp}=    Update Lead    ${leUid2}    ${title1}    ${desc1}    ${status_id}      ${priority_id2}    ${locId}    ${pcons_id3}    ${u_id1}   
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}"

JD-TC-UpdateLead-UH12

    [Documentation]  update a lead with consumer login.

    ${resp}=  Consumer Login  ${CUSERNAME17}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Update Lead    ${leUid2}    ${title1}    ${desc1}    ${status_id}      ${priority_id2}    ${locId}    ${pcons_id3}    ${u_id1}    
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    401
    Should Be Equal As Strings  "${resp.json()}"   "${NoAccess}"


*** Comments ***

JD-TC-UpdateLead-20

    [Documentation]  update a lead after change the status to closed.

    ${resp}=  Encrypted Provider Login  ${PUSERNAME_U1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=    Update Lead    ${leUid2}    ${title1}    ${desc1}    ${status_id}      ${priority_id2}    ${locId}    ${pcons_id3}    ${u_id1}    
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200