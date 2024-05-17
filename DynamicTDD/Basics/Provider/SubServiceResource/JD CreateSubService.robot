*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        SubService
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/Imageupload.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/musers.py


*** Test Cases ***


JD-TC-CreateSubService-1

    [Documentation]  Create a sub service in account level. 
    
    ${resp}=  Encrypted Provider Login  ${MUSERNAME170}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=  Get Account Settings
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Business Profile
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${account_id}  ${resp.json()['id']}
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}

    ${resp}=  View Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=  Toggle Department Enable
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${locId}=  Create Sample Location
    ELSE
        Set Suite Variable  ${locId}  ${resp.json()[0]['id']}
        Set Suite Variable  ${tz}  ${resp.json()[0]['place']}
    END

    ${resp}=  Get Departments
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    IF   '${resp.content}' == '${emptylist}'
        ${dep_name1}=  FakerLibrary.bs
        ${dep_code1}=   Random Int  min=100   max=999
        ${dep_desc1}=   FakerLibrary.word  
        ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
        Set Suite Variable  ${dep_id}  ${resp1.json()}
    ELSE
        Set Suite Variable  ${dep_id}  ${resp.json()['departments'][0]['departmentId']}
    END

    ${resp}=  Get User
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF   not '${resp.content}' == '${emptylist}'
        ${len}=  Get Length  ${resp.json()}
        FOR   ${i}  IN RANGE   0   ${len}
            Set Test Variable   ${user_phone}   ${resp.json()[${i}]['mobileNo']}
            IF   not '${user_phone}' == '${MUSERNAME170}'
                clear_users  ${user_phone}
            END
        END
    END

    ${u_id}=  Create Sample User
    Set Suite Variable  ${u_id}

    ${resp}=  Get User By Id  ${u_id}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${BUSER_U1}  ${resp.json()['mobileNo']}

    ${u_id1}=  Create Sample User
    Set Suite Variable  ${u_id1}

    ${resp}=  Get User By Id  ${u_id1}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${BUSER_U2}  ${resp.json()['mobileNo']}

    ${desc}=  FakerLibrary.sentence
    ${subser_dur}=   Random Int   min=5   max=10
    ${subser_price}=   Random Int   min=100   max=500
    ${subser_price}=  Convert To Number  ${subser_price}  1
    ${subser_name}=    FakerLibrary.firstname

    ${resp}=  Create Service    ${subser_name}  ${desc}  ${subser_dur}   ${status[0]}    ${btype}  ${bool[1]}    ${notifytype[2]}   ${EMPTY}   ${subser_price}
    ...    ${bool[0]}   ${bool[0]}   department=${dep_id}  serviceCategory=${serviceCategory[0]}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${subser_id1}  ${resp.json()}

    ${resp}=   Get Service By Id  ${subser_id1}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}                  ${subser_name} 
    Should Be Equal As Strings  ${resp.json()['serviceCategory']}       ${serviceCategory[0]}

JD-TC-CreateSubService-2

    [Documentation]  Create a sub service in user level. 
    
    ${resp}=  SendProviderResetMail   ${BUSER_U1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${BUSER_U1}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${BUSER_U1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${desc}=  FakerLibrary.sentence
    ${subser_dur}=   Random Int   min=5   max=10
    ${subser_price}=   Random Int   min=100   max=500
    ${subser_price}=  Convert To Number  ${subser_price}  1
    ${subser_name}=    FakerLibrary.firstname

    ${resp}=  Create Service For User   ${subser_name}  ${desc}  ${subser_dur}   ${status[0]}    ${btype}  ${bool[1]}    ${notifytype[2]}   ${EMPTY}   ${subser_price}  
    ...   ${bool[0]}   ${bool[0]}   ${dep_id}  ${u_id}   serviceCategory=${serviceCategory[0]}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${subser_id1}  ${resp.json()}

    ${resp}=   Get Service By Id  ${subser_id1}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}                  ${subser_name} 
    Should Be Equal As Strings  ${resp.json()['serviceCategory']}       ${serviceCategory[0]}

JD-TC-CreateSubService-3

    [Documentation]  Create multiple sub services for a user.
    
    ${resp}=  SendProviderResetMail   ${BUSER_U1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${BUSER_U1}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${BUSER_U1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${desc1}=  FakerLibrary.sentence
    ${subser_dur1}=   Random Int   min=5   max=10
    ${subser_price1}=   Random Int   min=100   max=500
    ${subser_price1}=  Convert To Number  ${subser_price1}  1
    ${subser_name1}=    FakerLibrary.firstname

    ${resp}=  Create Service For User   ${subser_name1}  ${desc1}  ${subser_dur1}   ${status[0]}    ${btype}  ${bool[1]}    ${notifytype[2]}   ${EMPTY}   ${subser_price1}  
    ...   ${bool[0]}   ${bool[0]}   ${dep_id}  ${u_id}   serviceCategory=${serviceCategory[0]}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${subser_id1}  ${resp.json()}

    ${desc2}=  FakerLibrary.sentence
    ${subser_dur2}=   Random Int   min=5   max=10
    ${subser_price2}=   Random Int   min=100   max=500
    ${subser_price2}=  Convert To Number  ${subser_price2}  1
    ${subser_name2}=    FakerLibrary.firstname

    ${resp}=  Create Service For User   ${subser_name2}  ${desc2}  ${subser_dur2}   ${status[0]}    ${btype}  ${bool[1]}    ${notifytype[2]}   ${EMPTY}   ${subser_price2}  
    ...   ${bool[0]}   ${bool[0]}   ${dep_id}  ${u_id}   serviceCategory=${serviceCategory[0]}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${subser_id2}  ${resp.json()}

    ${resp}=   Get Service By Id  ${subser_id1}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}                  ${subser_name1} 
    Should Be Equal As Strings  ${resp.json()['serviceCategory']}       ${serviceCategory[0]}

    ${resp}=   Get Service By Id  ${subser_id2}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}                  ${subser_name2} 
    Should Be Equal As Strings  ${resp.json()['serviceCategory']}       ${serviceCategory[0]}


JD-TC-CreateSubService-4

    [Documentation]  Create a sub service for a user and check it can be accessable by another user of the same account.
    
    ${resp}=  SendProviderResetMail   ${BUSER_U1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${BUSER_U1}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${BUSER_U1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${desc1}=  FakerLibrary.sentence
    ${subser_dur1}=   Random Int   min=5   max=10
    ${subser_price1}=   Random Int   min=100   max=500
    ${subser_price1}=  Convert To Number  ${subser_price1}  1
    ${subser_name1}=    FakerLibrary.firstname

    ${resp}=  Create Service For User   ${subser_name1}  ${desc1}  ${subser_dur1}   ${status[0]}    ${btype}  ${bool[1]}    ${notifytype[2]}   ${EMPTY}   ${subser_price1}  
    ...   ${bool[0]}   ${bool[0]}   ${dep_id}  ${u_id}   serviceCategory=${serviceCategory[0]}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${subser_id1}  ${resp.json()}

    ${resp}=  SendProviderResetMail   ${BUSER_U2}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${BUSER_U2}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${BUSER_U2}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Service By Id  ${subser_id1}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}                  ${subser_name1} 
    Should Be Equal As Strings  ${resp.json()['serviceCategory']}       ${serviceCategory[0]}

JD-TC-CreateSubService-5

    [Documentation]  Create a service and sub service in account level. 
    
    ${resp}=  Encrypted Provider Login  ${MUSERNAME170}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${desc}=  FakerLibrary.sentence
    ${subser_dur}=   Random Int   min=5   max=10
    ${subser_price}=   Random Int   min=100   max=500
    ${subser_price}=  Convert To Number  ${subser_price}  1
    ${subser_name}=    FakerLibrary.firstname

    ${resp}=  Create Service    ${subser_name}  ${desc}  ${subser_dur}   ${status[0]}    ${btype}  ${bool[1]}    ${notifytype[2]}   ${EMPTY}   ${subser_price}
    ...    ${bool[0]}   ${bool[0]}   department=${dep_id}  serviceCategory=${serviceCategory[0]}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${subser_id1}  ${resp.json()}

    ${resp}=   Get Service By Id  ${subser_id1}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}                  ${subser_name} 
    Should Be Equal As Strings  ${resp.json()['serviceCategory']}       ${serviceCategory[0]}

    ${desc1}=  FakerLibrary.sentence
    ${ser_dur}=   Random Int   min=5   max=10
    ${ser_price}=   Random Int   min=100   max=500
    ${ser_price}=  Convert To Number  ${ser_price}  1
    ${ser_name}=    FakerLibrary.firstname

    ${resp}=  Create Service    ${ser_name}  ${desc1}  ${ser_dur}   ${status[0]}    ${btype}  ${bool[1]}    ${notifytype[2]}   ${EMPTY}   ${ser_price}
    ...    ${bool[0]}   ${bool[0]}   department=${dep_id}  serviceCategory=${serviceCategory[1]}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${ser_id1}  ${resp.json()}

    ${resp}=   Get Service By Id  ${ser_id1}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}                  ${ser_name} 
    Should Be Equal As Strings  ${resp.json()['serviceCategory']}       ${serviceCategory[1]}


JD-TC-CreateSubService-6

    [Documentation]  Create a service and a sub services for a user.
    
    ${resp}=  SendProviderResetMail   ${BUSER_U1}
    Should Be Equal As Strings  ${resp.status_code}  200

    @{resp}=  ResetProviderPassword  ${BUSER_U1}  ${PASSWORD}  ${OtpPurpose['ProviderResetPassword']}
    Should Be Equal As Strings  ${resp[0].status_code}  200
    Should Be Equal As Strings  ${resp[1].status_code}  200

    ${resp}=  Encrypted Provider Login  ${BUSER_U1}  ${PASSWORD}
    Log   ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${desc1}=  FakerLibrary.sentence
    ${subser_dur1}=   Random Int   min=5   max=10
    ${subser_price1}=   Random Int   min=100   max=500
    ${subser_price1}=  Convert To Number  ${subser_price1}  1
    ${subser_name1}=    FakerLibrary.firstname

    ${resp}=  Create Service For User   ${subser_name1}  ${desc1}  ${subser_dur1}   ${status[0]}    ${btype}  ${bool[1]}    ${notifytype[2]}   ${EMPTY}   ${subser_price1}  
    ...   ${bool[0]}   ${bool[0]}   ${dep_id}  ${u_id}   serviceCategory=${serviceCategory[0]}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${subser_id1}  ${resp.json()}

    ${desc}=  FakerLibrary.sentence
    ${ser_dur}=   Random Int   min=5   max=10
    ${ser_price}=   Random Int   min=100   max=500
    ${ser_price}=  Convert To Number  ${ser_price}  1
    ${ser_name}=    FakerLibrary.firstname

    ${resp}=  Create Service For User   ${ser_name}  ${desc}  ${ser_dur}   ${status[0]}    ${btype}  ${bool[1]}    ${notifytype[2]}   ${EMPTY}   ${ser_price}
    ...    ${bool[0]}   ${bool[0]}   ${dep_id}  ${u_id}   serviceCategory=${serviceCategory[1]}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${ser_id1}  ${resp.json()}

    ${resp}=   Get Service By Id  ${subser_id1}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}                  ${subser_name1} 
    Should Be Equal As Strings  ${resp.json()['serviceCategory']}       ${serviceCategory[0]}

    ${resp}=   Get Service By Id  ${ser_id1}
    Log   ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}                  ${ser_name} 
    Should Be Equal As Strings  ${resp.json()['serviceCategory']}       ${serviceCategory[1]}


JD-TC-CreateSubService-UH1

    [Documentation]  Create a sub service without name. 
    
    ${resp}=  Encrypted Provider Login  ${MUSERNAME170}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${desc}=  FakerLibrary.sentence
    ${subser_dur}=   Random Int   min=5   max=10
    ${subser_price}=   Random Int   min=100   max=500
    ${subser_price}=  Convert To Number  ${subser_price}  1
    ${subser_name}=    FakerLibrary.firstname

    ${resp}=  Create Service    ${EMPTY}  ${desc}  ${subser_dur}   ${status[0]}    ${btype}  ${bool[1]}    ${notifytype[2]}   ${EMPTY}   ${subser_price}
    ...    ${bool[0]}   ${bool[0]}   department=${dep_id}  serviceCategory=${serviceCategory[0]}
    Log   ${resp.json()}  
    Should Be Equal As Strings    ${resp.status_code}    422
    Should Be Equal As Strings    ${resp.json()}    ${SERVICE_NAME_REQUIRED}