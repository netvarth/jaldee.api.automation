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

${self}   0


*** Test Cases ***

JD-TC-Get Coupon By Id-1

    [Documentation]   Provider check to get Coupon By Id

    ${resp}=  Encrypted Provider Login  ${PUSERNAME172}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    clear_Coupon   ${PUSERNAME172}
    clear_service       ${PUSERNAME172}
    clear_location   ${PUSERNAME172}
    clear_Item    ${PUSERNAME172}
    clear_customer   ${PUSERNAME172}
    # ${desc}=  FakerLibrary.Sentence   nb_words=2
    # ${amount}=  FakerLibrary.Pyfloat  positive=True  left_digits=2  right_digits=1
    # ${type}=  Random Element  ${calctype}
    # ${resp}=  Create Coupon  ${coupon}  ${desc}  ${amount}  ${type}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Test Variable  ${coupid}  ${resp.json()}
    # ${desc2}=  FakerLibrary.Sentence   nb_words=2
    # ${amount2}=  FakerLibrary.Pyfloat  positive=True  left_digits=2  right_digits=1
    # ${type2}=  Random Element  ${calctype}
    # ${resp}=  Create Coupon  ${coupon2}  ${desc2}  ${amount2}  ${type2}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${coupid2}  ${resp.json()}

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
    
    ${coupon}=    FakerLibrary.firstname
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    ${amount}=  FakerLibrary.Pyfloat  positive=True  left_digits=3  right_digits=1
    ${cupn_code}=   FakerLibrary.word
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${ST_DAY}=  db.get_date_by_timezone  ${tz}
    ${EN_DAY}=  db.add_timezone_date  ${tz}   10
    ${min_bill_amount}=   Random Int   min=100   max=1000
    ${min_bill_amount}=   Convert To Number   ${min_bill_amount}

    ${max_disc_val}=   Random Int   min=100   max=500
    ${max_disc_val}=   Convert To Number   ${max_disc_val}
    
    ${max_prov_use}=   Random Int   min=10   max=20
    ${book_channel}=   Create List   ${bookingChannel[0]}
    ${coupn_based}=  Create List   ${couponBasedOn[0]}
    ${tc}=  FakerLibrary.sentence
    ${services}=   Create list   ${sid1}   ${sid2}
    ${resp}=  Create Provider Coupon   ${coupon}  ${desc}  ${amount}  ${calctype[1]}  ${cupn_code}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[1]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}  services=${services}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${coupid}  ${resp.json()}
    
    ${coupon2}=    FakerLibrary.word
    ${desc2}=  FakerLibrary.Sentence   nb_words=2
    ${amount2}=  FakerLibrary.Pyfloat  positive=True  left_digits=3  right_digits=1
    ${cupn_code2}=   FakerLibrary.word
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${ST_DAY}=  db.get_date_by_timezone  ${tz}
    ${EN_DAY}=  db.add_timezone_date  ${tz}   10
    ${min_bill_amount2}=   Random Int   min=10   max=100
    ${max_disc_val2}=   Random Int   min=100   max=500
    ${max_prov_use2}=   Random Int   min=10   max=20
    ${book_channel}=   Create List   ${bookingChannel[0]}
    ${coupn_based}=  Create List   ${couponBasedOn[0]}
    ${tc2}=  FakerLibrary.sentence
    ${services}=   Create list   ${sid1}   ${sid2}
    ${resp}=  Create Provider Coupon   ${coupon2}  ${desc2}  ${amount2}  ${calctype[1]}  ${cupn_code2}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[1]}  ${min_bill_amount2}  ${max_disc_val2}  ${bool[1]}  ${max_prov_use2}  ${book_channel}  ${coupn_based}  ${tc2}   services=${services}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${coupid2}  ${resp.json()}
    
    ${resp}=  Get Coupon By Id  ${coupid} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['name']}                                               ${coupon}
    Should Be Equal As Strings  ${resp.json()['description']}                                        ${desc}  
    Should Be Equal As Strings  ${resp.json()['amount']}                                             ${amount}
    Should Be Equal As Strings  ${resp.json()['calculationType']}                                    ${calctype[1]}  
    Should Be Equal As Strings  ${resp.json()['status']}                                             ${status[0]}
    Should Be Equal As Strings  ${resp.json()['couponCode']}                                         ${cupn_code}  
    Should Be Equal As Strings  ${resp.json()['couponRules']['minBillAmount']}                       ${min_bill_amount}
    Should Be Equal As Strings  ${resp.json()['couponRules']['maxDiscountValue']}                    ${max_disc_val}
    Should Be Equal As Strings  ${resp.json()['couponRules']['maxProviderUseLimit']}                 ${max_prov_use}
    Should Be Equal As Strings  ${resp.json()['couponRules']['firstCheckinOnly']}                    ${bool[1]}
    Should Be Equal As Strings  ${resp.json()['couponRules']['startDate']}                           ${ST_DAY}
    Should Be Equal As Strings  ${resp.json()['couponRules']['endDate']}                             ${EN_DAY}
    Should Be Equal As Strings  ${resp.json()['couponRules']['published']}                           ${bool[0]}
    # Should Be Equal As Strings  ${resp.json()['couponRules']['policies']['services']}                               ${services}
    Should Be Equal As Strings  ${resp.json()['couponRules']['validTimeRange'][0]['recurringType']}                 ${recurringtype[1]}  
    Should Be Equal As Strings  ${resp.json()['couponRules']['validTimeRange'][0]['repeatIntervals']}               ${list}  
    Should Be Equal As Strings  ${resp.json()['couponRules']['validTimeRange'][0]['startDate']}                     ${ST_DAY}  
    Should Be Equal As Strings  ${resp.json()['couponRules']['validTimeRange'][0]['terminator']['endDate']}         ${EN_DAY}  
    Should Be Equal As Strings  ${resp.json()['couponRules']['validTimeRange'][0]['terminator']['noOfOccurance']}   ${self}  
    Should Be Equal As Strings  ${resp.json()['couponRules']['validTimeRange'][0]['timeSlots'][0]['sTime']}         ${sTime}  
    Should Be Equal As Strings  ${resp.json()['couponRules']['validTimeRange'][0]['timeSlots'][0]['eTime']}         ${eTime}  
    Should Be Equal As Strings  ${resp.json()['bookingChannel']}                                     ${book_channel}
    Should Be Equal As Strings  ${resp.json()['couponBasedOn']}                                      ${coupn_based}  
    Should Be Equal As Strings  ${resp.json()['termsConditions']}                                    ${tc}
    
    ${resp}=  Get Coupon By Id  ${coupid2} 
    Verify Response  ${resp}  name=${coupon2}  description=${desc2}  amount=${amount2}  calculationType=${calctype[1]}  status=${status[0]}

JD-TC-Get Coupon By Id-UH1

    [Documentation]   Consumer check to get Coupon By Id 

    ${resp}=  ConsumerLogin  ${CUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Coupon By Id  ${coupid2}    
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"   "${LOGIN_NO_ACCESS_FOR_URL}"   

JD-TC-Get Coupon By Id-UH2

    [Documentation]  get Coupon By Id without login

    ${resp}=  Get Coupon By Id  ${coupid2}   
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"   "${SESSION_EXPIRED}"   

JD-TC-Get Coupon By Id-UH3

    [Documentation]   Provider check  get Coupon By Id of invalid id

    ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Coupon By Id  0 
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${INCORRECT_COUPON_ID}"
    
JD-TC-Get Coupon By Id-UH4

    [Documentation]   Provider check to get Coupon By Id another providr's coupon id

    ${resp}=  Encrypted Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200   

    ${resp}=  Get Coupon By Id  ${coupid2} 
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  "${resp.json()}"  "${INCORRECT_COUPON_ID}"