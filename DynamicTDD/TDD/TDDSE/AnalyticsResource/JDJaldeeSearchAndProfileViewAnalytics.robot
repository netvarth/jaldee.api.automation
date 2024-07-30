*** Settings ***
Suite Teardown    Run Keywords  Delete All Sessions  
Test Teardown     Run Keywords  Delete All Sessions  
Force Tags        Analytics Search and Profile View
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/Keywords.robot
Resource          /ebs/TDD/AppKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/consumermail.py


*** Variables ***

${count}       ${10}
${count1}      ${15}
${count2}      ${4}
${self}        0
${CUSERPH}     ${CUSERNAME}
${start}       11
${def_amt}     0.0
&{ios_sp_headers}        Content-Type=application/json  User-Agent=iphone  BOOKING_REQ_FROM=SP_APP  
&{sp_app_headers}        Content-Type=application/json  User-Agent=android  BOOKING_REQ_FROM=SP_APP   
&{jaldee_link_headers}   Content-Type=application/json  BOOKING_REQ_FROM=WEB_LINK


*** Test Cases ***


JD-TC-JaldeeSearchandProfileViewAnalytics-1

    [Documentation]  check JALDEE_WEB_SEARCH_COUNT.

    ${pid}=  get_acc_id  ${PUSERNAME10}
    Set Suite Variable  ${pid}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME10}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}

    FOR   ${a}  IN RANGE   ${count}

        ${resp}=  Get Waiting Time Of Providers  ${pid}-${lid}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200  
    END 

    sleep  01s
    # sleep  05m
       
    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${resp}=  Get Account Level Analytics  metricId=${SearchViewAnalyticsMetrics['JALDEE_WEB_SEARCH_COUNT']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}     ${count}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}    ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${SearchViewAnalyticsMetrics['JALDEE_WEB_SEARCH_COUNT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

JD-TC-JaldeeSearchandProfileViewAnalytics-2

    [Documentation]  check JALDEE_WEB_BUS_PROFILE_VIEW_COUNT.
    
    ${pid}=  get_acc_id  ${PUSERNAME11}
    Set Test Variable  ${pid}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${resp}=  Encrypted Provider Login  ${PUSERNAME11}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    Get Locations
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${lid}   ${resp.json()[0]['id']}

    FOR   ${a}  IN RANGE   ${count}

        ${resp}=  Get Waiting Time Of Providers  ${pid}-${lid}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200  
    END 

    sleep  01s
    # sleep  05m
       
    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${resp}=  Get Account Level Analytics  metricId=${SearchViewAnalyticsMetrics['JALDEE_WEB_BUS_PROFILE_VIEW_COUNT']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}     ${count}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}    ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${SearchViewAnalyticsMetrics['JALDEE_WEB_BUS_PROFILE_VIEW_COUNT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}


JD-TC-JaldeeSearchandProfileViewAnalytics-3

    [Documentation]  check JALDEE_IOS_APP_SEARCH_COUNT.

    ${pid}=  get_acc_id  ${PUSERNAME12}
    Set Test Variable  ${pid}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${resp}=  App ProviderLogin  ${ios_sp_headers}  ${PUSERNAME12}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    App Get Locations  ${ios_sp_headers}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}

    FOR   ${a}  IN RANGE   ${count}

        ${resp}=  App Get Waiting Time Of Providers  ${ios_sp_headers}  ${pid}-${lid}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200  
    END 
    
    ${resp}=   App ProviderLogout  ${ios_sp_headers}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Encrypted Provider Login   ${PUSERNAME12}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    sleep  01s
    # sleep  05m
       
    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${resp}=  Get Account Level Analytics  metricId=${SearchViewAnalyticsMetrics['JALDEE_IOS_APP_SEARCH_COUNT']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}     ${count}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}    ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${SearchViewAnalyticsMetrics['JALDEE_IOS_APP_SEARCH_COUNT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}


JD-TC-JaldeeSearchandProfileViewAnalytics-4

    [Documentation]  check JALDEE_ANDROID_APP_SEARCH_COUNT.

    ${pid}=  get_acc_id  ${PUSERNAME13}
    Set Test Variable  ${pid}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${resp}=  App ProviderLogin  ${sp_app_headers}  ${PUSERNAME13}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    App Get Locations  ${sp_app_headers}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}

    FOR   ${a}  IN RANGE   ${count}

        ${resp}=  App Get Waiting Time Of Providers  ${sp_app_headers}  ${pid}-${lid}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200  
    END 
    
    ${resp}=   App ProviderLogout  ${sp_app_headers}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Encrypted Provider Login   ${PUSERNAME13}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    sleep  01s
    # sleep  05m
       
    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${resp}=  Get Account Level Analytics  metricId=${SearchViewAnalyticsMetrics['JALDEE_ANDROID_APP_SEARCH_COUNT']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}     ${count}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}    ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${SearchViewAnalyticsMetrics['JALDEE_ANDROID_APP_SEARCH_COUNT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}


JD-TC-JaldeeSearchandProfileViewAnalytics-5

    [Documentation]  check JALDEE_IOS_APP_BUS_PROFILE_VIEW_COUNT.

    ${pid}=  get_acc_id  ${PUSERNAME15}
    Set Test Variable  ${pid}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${resp}=  App ProviderLogin  ${ios_sp_headers}  ${PUSERNAME15}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    App Get Locations  ${ios_sp_headers}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}

    FOR   ${a}  IN RANGE   ${count}

        ${resp}=  App Get Waiting Time Of Providers  ${ios_sp_headers}  ${pid}-${lid}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200  
    END 
    
    ${resp}=   App ProviderLogout  ${ios_sp_headers}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Encrypted Provider Login   ${PUSERNAME15}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    sleep  01s
    # sleep  10m
       
    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${resp}=  Get Account Level Analytics  metricId=${SearchViewAnalyticsMetrics['JALDEE_IOS_APP_BUS_PROFILE_VIEW_COUNT']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}     ${count}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}    ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${SearchViewAnalyticsMetrics['JALDEE_IOS_APP_BUS_PROFILE_VIEW_COUNT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}



JD-TC-JaldeeSearchandProfileViewAnalytics-6

    [Documentation]  check JALDEE_ANDROID_APP_BUS_PROFILE_VIEW_COUNT.

    ${pid}=  get_acc_id  ${PUSERNAME14}
    Set Test Variable  ${pid}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${resp}=  App ProviderLogin  ${sp_app_headers}  ${PUSERNAME14}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    App Get Locations  ${sp_app_headers}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}

    FOR   ${a}  IN RANGE   ${count}

        ${resp}=  App Get Waiting Time Of Providers  ${sp_app_headers}  ${pid}-${lid}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200  
    END 
    
    ${resp}=   App ProviderLogout  ${sp_app_headers}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Encrypted Provider Login   ${PUSERNAME14}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    sleep  01s
    # sleep  10m
       
    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${resp}=  Get Account Level Analytics  metricId=${SearchViewAnalyticsMetrics['JALDEE_ANDROID_APP_BUS_PROFILE_VIEW_COUNT']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}     ${count}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}    ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${SearchViewAnalyticsMetrics['JALDEE_ANDROID_APP_BUS_PROFILE_VIEW_COUNT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}


JD-TC-JaldeeSearchandProfileViewAnalytics-7

    [Documentation]  check SP_LINK_BUS_PROFILE_VIEW_COUNT.

    ${pid}=  get_acc_id  ${PUSERNAME16}
    Set Test Variable  ${pid}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${resp}=  App ProviderLogin  ${jaldee_link_headers}  ${PUSERNAME16}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=    App Get Locations  ${jaldee_link_headers}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}

    FOR   ${a}  IN RANGE   ${count}

        ${resp}=  App Get Waiting Time Of Providers  ${jaldee_link_headers}  ${pid}-${lid}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200  
    END 
    
    ${resp}=   App ProviderLogout  ${jaldee_link_headers}
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Encrypted Provider Login   ${PUSERNAME16}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    sleep  01s
    # sleep  05m
       
    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${resp}=  Get Account Level Analytics  metricId=${SearchViewAnalyticsMetrics['SP_LINK_BUS_PROFILE_VIEW_COUNT']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}     ${count}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}    ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${SearchViewAnalyticsMetrics['SP_LINK_BUS_PROFILE_VIEW_COUNT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}



JD-TC-JaldeeSearchandProfileViewAnalytics-8

    [Documentation]  check SP_LINK_BUS_PROFILE_VIEW_COUNT.

    ${pid}=  get_acc_id  ${PUSERNAME19}
    Set Test Variable  ${pid}
    
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    ${resp}=  Encrypted Provider Login   ${PUSERNAME19}  ${PASSWORD}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${resp}=   Get Locations 
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}   ${resp.json()[0]['id']}

    FOR   ${a}  IN RANGE   ${count}

        ${resp}=  Get Waiting Time Of Providers   ${pid}-${lid}
        Log   ${resp.json()}
        Should Be Equal As Strings  ${resp.status_code}  200  
    END 
    
    ${resp}=   ProviderLogout  
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=   Encrypted Provider Login   ${PUSERNAME19}  ${PASSWORD} 
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}   200

    sleep  01s
    # sleep  10m
       
    FOR   ${a}  IN RANGE   15
       
        ${resp}=  Flush Analytics Data to DB
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
        sleep  1s
        Exit For Loop If    ${resp.content}=="FREE"
    
    END

    ${resp}=  Get Account Level Analytics  metricId=${SearchViewAnalyticsMetrics['SP_LINK_BUS_PROFILE_VIEW_COUNT']}  dateFrom=${DAY1}  dateTo=${DAY1}  frequency=${analyticsFrequency[0]}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['frequency']}                    ${analyticsFrequency[0]}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['value']}     ${count}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['amount']}    ${def_amt}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['metricId']}  ${SearchViewAnalyticsMetrics['SP_LINK_BUS_PROFILE_VIEW_COUNT']}
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['metricValues'][0]['dateFor']}   ${DAY1}

