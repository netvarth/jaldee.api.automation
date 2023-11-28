*** Settings ***
Suite Teardown    Run Keywords  Delete All Sessions  
Test Teardown     Run Keywords  Delete All Sessions  
Force Tags        Consumer Count Analytics
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/consumermail.py
Resource          /ebs/TDD/AppKeywords.robot

*** Variables ***

${digits}      0123456789
${ZOOM_url}    https://zoom.us/j/{}?pwd=THVLcTBZa2lESFZQbU9DQTQrWUxWZz09
${self}        0
@{empty_list}  
${count}       ${9}
${CUSERPH}      ${CUSERNAME}

*** Test Cases ***

# JD-TC-WEB_NEW_CONSUMER_COUNT-1

#     [Documentation]   WEB_NEW_CONSUMER_COUNT metrics

#     clear_customer   ${PUSERNAME152}
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${pid}=  get_acc_id  ${PUSERNAME152}

#     FOR   ${a}  IN RANGE   ${count}

#         ${CO_Number}    Generate random string    7    0123456789
#         ${CO_Number}    Convert To Integer  ${CO_Number}
#         ${CUSERPH0}=  Evaluate  ${CUSERNAME}+${CO_Number}
#         Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH0}${\n}
#         Set Test Variable   ${CUSERPH0}   

#         ${DAY1}=  db.get_date_by_timezone  ${tz}
#         ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH0}+1000
#         ${firstname}=  FakerLibrary.first_name
#         ${lastname}=  FakerLibrary.last_name
#         ${address}=  FakerLibrary.address
#         ${dob}=  FakerLibrary.Date
#         ${gender}    Random Element    ${Genderlist}
#         ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH0}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}
#         Log  ${resp.content}
#         Should Be Equal As Strings    ${resp.status_code}    200

        ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH0}+1000
        ${firstname}=  FakerLibrary.first_name
        ${lastname}=  FakerLibrary.last_name
        ${email}=   FakerLibrary.email
        ${resp}=  Consumer SignUp Via QRcode   ${firstname}  ${lastname}  ${CUSERPH0}   ${countryCodes[0]}  ${pid}  ${email}
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

#         ${resp}=  Consumer Activation  ${email}  1
#         Log  ${resp.content}
#         Should Be Equal As Strings    ${resp.status_code}    200

#         ${resp}=  Consumer Set Credential  ${email}  ${PASSWORD}  1
#         Log  ${resp.content}
#         Should Be Equal As Strings    ${resp.status_code}    200

#         ${resp}=  Consumer Login  ${CUSERPH0}  ${PASSWORD}
#         Log  ${resp.content}
#         Should Be Equal As Strings    ${resp.status_code}    200

#         ${resp}=  Consumer Logout
#         Log  ${resp.content}
#         Should Be Equal As Strings    ${resp.status_code}    200

#     END

#     ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200   

#     ${resp}=  GetCustomer  
#     Log   ${resp.json()}
#     Should Be Equal As Strings      ${resp.status_code}  200

#     FOR   ${a}  IN RANGE   15
       
#         ${resp}=  Flush Analytics Data to DB
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         sleep  3s
#         Exit For Loop If    ${resp.content}=="FREE"
    
#     END

#     ${resp}=  Get Account Level Analytics  ${consumerAnalyticsMetrics['WEB_NEW_CONSUMER_COUNT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
#     Log  ${resp.content}

#     # ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
#     # Log   ${resp.json()}
#     # Should Be Equal As Strings  ${resp.status_code}  200

#     # ${resp}=   Account Level Analytics  metricId=${consumerAnalyticsMetrics['WEB_NEW_CONSUMER_COUNT']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=${analyticsFrequency[0]}
#     # Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200  
#     # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
#     # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${consumerAnalyticsMetrics['WEB_NEW_CONSUMER_COUNT']}
#     # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${phonein_token_len}
#     # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
#     # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}




JD-TC-WEB_NEW_CONSUMER_COUNT-1

    [Documentation]   WEB_NEW_CONSUMER_COUNT metrics

    clear_customer   ${PUSERNAME153}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME153}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${pid}=  get_acc_id  ${PUSERNAME153}
    ${DAY1}=  db.get_date_by_timezone  ${tz}

    FOR   ${a}  IN RANGE   ${count}
            
        ${resp}=  AddCustomer  ${CUSERNAME${a}} 
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Set Test Variable  ${cid${a}}   ${resp.json()}

        ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME${a}}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        Should Be Equal As Strings  ${resp.json()[0]['id']}  ${cid${a}}

    END

    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${resp}=  Get Account Level Analytics  ${consumerAnalyticsMetrics['WEB_NEW_CONSUMER_COUNT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200

JD-TC-WEB_NEW_CONSUMER_COUNT-1

#     [Documentation]   WEB_NEW_CONSUMER_COUNT metrics

#     clear_customer   ${PUSERNAME152}
#     ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
#     Log  ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200

#     ${pid}=  get_acc_id  ${PUSERNAME152}

#     FOR   ${a}  IN RANGE   ${count}

#         ${CO_Number}    Generate random string    7    0123456789
#         ${CO_Number}    Convert To Integer  ${CO_Number}
#         ${CUSERPH0}=  Evaluate  ${CUSERNAME}+${CO_Number}
#         Append To File  ${EXECDIR}/TDD/numbers.txt  ${CUSERPH0}${\n}
#         Set Test Variable   ${CUSERPH0}   

#         ${DAY1}=  db.get_date_by_timezone  ${tz}
#         ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH0}+1000
#         ${firstname}=  FakerLibrary.first_name
#         ${lastname}=  FakerLibrary.last_name
#         ${address}=  FakerLibrary.address
#         ${dob}=  FakerLibrary.Date
#         ${gender}    Random Element    ${Genderlist}
#         ${resp}=  Consumer SignUp  ${firstname}  ${lastname}  ${address}  ${CUSERPH0}  ${CUSERPH_SECOND}  ${dob}  ${gender}   ${EMPTY}
#         Log  ${resp.content}
#         Should Be Equal As Strings    ${resp.status_code}    200

        ${CUSERPH_SECOND}=  Evaluate  ${CUSERPH0}+1000
        ${firstname}=  FakerLibrary.first_name
        ${lastname}=  FakerLibrary.last_name
        ${email}=   FakerLibrary.email
        ${resp}=  Consumer SignUp Via QRcode   ${firstname}  ${lastname}  ${CUSERPH0}   ${countryCodes[0]}  ${pid}  ${email}
        Log  ${resp.content}
        Should Be Equal As Strings    ${resp.status_code}    200

#         ${resp}=  Consumer Activation  ${email}  1
#         Log  ${resp.content}
#         Should Be Equal As Strings    ${resp.status_code}    200

#         ${resp}=  Consumer Set Credential  ${email}  ${PASSWORD}  1
#         Log  ${resp.content}
#         Should Be Equal As Strings    ${resp.status_code}    200

#         ${resp}=  Consumer Login  ${CUSERPH0}  ${PASSWORD}
#         Log  ${resp.content}
#         Should Be Equal As Strings    ${resp.status_code}    200

#         ${resp}=  Consumer Logout
#         Log  ${resp.content}
#         Should Be Equal As Strings    ${resp.status_code}    200

#     END

#     ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
#     Log   ${resp.json()}
#     Should Be Equal As Strings    ${resp.status_code}    200   

#     ${resp}=  GetCustomer  
#     Log   ${resp.json()}
#     Should Be Equal As Strings      ${resp.status_code}  200

#     FOR   ${a}  IN RANGE   15
       
#         ${resp}=  Flush Analytics Data to DB
#         Log  ${resp.content}
#         Should Be Equal As Strings  ${resp.status_code}  200
#         sleep  3s
#         Exit For Loop If    ${resp.content}=="FREE"
    
#     END

#     ${resp}=  Get Account Level Analytics  ${consumerAnalyticsMetrics['WEB_NEW_CONSUMER_COUNT']}  ${DAY1}  ${DAY1}  ${analyticsFrequency[0]}
#     Log  ${resp.content}

#     # ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
#     # Log   ${resp.json()}
#     # Should Be Equal As Strings  ${resp.status_code}  200

#     # ${resp}=   Account Level Analytics  metricId=${consumerAnalyticsMetrics['WEB_NEW_CONSUMER_COUNT']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=${analyticsFrequency[0]}
#     # Log  ${resp.content}
#     Should Be Equal As Strings  ${resp.status_code}  200  
#     # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}   ${analyticsFrequency[0]}
#     # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${consumerAnalyticsMetrics['WEB_NEW_CONSUMER_COUNT']}
#     # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}   ${phonein_token_len}
#     # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}   ${def_amt}
#     # Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}


