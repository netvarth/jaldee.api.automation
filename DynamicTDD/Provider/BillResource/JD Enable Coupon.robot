*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Coupon
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

***Variables***
${coupon}    wheat

*** Test Cases ***
JD-TC-Enable coupon-1
    [Documentation]   Provider check to Enable coupon 
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME121}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    clear_Coupon   ${PUSERNAME121}

    # ${desc}=  FakerLibrary.Sentence   nb_words=2
    # ${amount}=  FakerLibrary.Pyfloat  positive=True  left_digits=2  right_digits=1
    # ${type}=  Random Element  ${calctype}
    # ${resp}=  Create Coupon  ${coupon}  ${desc}  ${amount}  ${type}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${value1}   ${resp.json()}

    ${description}=  FakerLibrary.sentence
    ${ser_durtn}=   Random Int   min=2   max=10
    ${ser_amount}=   Random Int   min=100   max=1000
    ${ser_amount1}=   Convert To Number   ${ser_amount}
    ${SERVICE1}=    FakerLibrary.word
    ${resp}=  Create Service  ${SERVICE1}   ${description}   ${ser_durtn}   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${EMPTY}  ${ser_amount1}  ${bool[0]}   ${bool[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Test Variable  ${sid1}  ${resp.json()}

    ${description1}=  FakerLibrary.sentence
    ${ser_durtn1}=   Random Int   min=2   max=10
    ${ser_amount}=   Random Int   min=100   max=1000
    ${ser_amount2}=   Convert To Number   ${ser_amount}
    ${SERVICE2}=    FakerLibrary.word
    ${resp}=  Create Service  ${SERVICE2}   ${description1}   ${ser_durtn1}   ${status[0]}   ${btype}    ${bool[1]}    ${notifytype[2]}  ${EMPTY}  ${ser_amount2}  ${bool[0]}   ${bool[0]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Test Variable  ${sid2}  ${resp.json()}
    
    ${coupon}=    FakerLibrary.word
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    ${amount}=  FakerLibrary.Pyfloat  positive=True  left_digits=3  right_digits=1
    ${cupn_code}=   FakerLibrary.word
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${ST_DAY}=  db.get_date_by_timezone  ${tz}
    ${EN_DAY}=  db.add_timezone_date  ${tz}   10
    ${min_bill_amount}=   Random Int   min=100   max=1000
    ${max_disc_val}=   Random Int   min=100   max=500
    ${max_prov_use}=   Random Int   min=10   max=20
    ${book_channel}=   Create List   ${bookingChannel[0]}
    ${coupn_based}=  Create List   ${couponBasedOn[0]}
    ${tc}=  FakerLibrary.sentence
    ${services}=   Create list   ${sid1}   ${sid2}
    ${resp}=  Create Provider Coupon   ${coupon}  ${desc}  ${amount}  ${calctype[1]}  ${cupn_code}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[1]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}  services=${services}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${value1}  ${resp.json()}

    ${resp}=  Get Coupon By Id  ${value1} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${coupon}  description=${desc}  amount=${amount}  calculationType=${calctype[1]}  status=${status[0]}
    
    ${resp}=  Disable Coupon  ${value1}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Coupon By Id  ${value1} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${coupon}  description=${desc}  amount=${amount}  calculationType=${calctype[1]}  status=${status[1]}
    
    ${resp}=  Enable Coupon  ${value1}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get Coupon By Id  ${value1} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${coupon}  description=${desc}  amount=${amount}  calculationType=${calctype[1]}  status=${status[0]}

JD-TC-Enable coupon-UH1

    [Documentation]   Enable a already enabled coupon
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME121}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Enable Coupon  ${value1}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${COUPON_ALREADY_ENABLED}"
        
JD-TC-Enable coupon-UH2

    [Documentation]    Consumer check to Enable coupon  
    
    ${resp}=  ConsumerLogin  ${CUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Enable Coupon  ${value1}   
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"   

JD-TC-Enable coupon-UH3
    
    [Documentation]  Enable coupon   without login 
    
    ${resp}=  Enable Coupon  ${value1}  
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"   
    
JD-TC-Enable coupon-UH4
    
    [Documentation]   Provider check to Enable coupon  with invalid coupon id
    
    ${resp}=  Encrypted Provider Login  ${PUSERNAME8}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Enable Coupon  0
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"   "${INCORRECT_COUPON_ID}" 
    
JD-TC-Enable coupon-UH5
    
    [Documentation]    Enable coupon  with another provider coupon id
    
    ${resp}=   Encrypted Provider Login  ${PUSERNAME8}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Enable Coupon  ${value1}   
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${INCORRECT_COUPON_ID}"