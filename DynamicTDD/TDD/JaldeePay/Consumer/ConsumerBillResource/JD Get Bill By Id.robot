*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Bill
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ProviderConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
# Variables         /ebs/TDD/varfiles/consumermail.py
 

*** Variables ***
@{action}       addService  adjustService  removeService  addItem   adjustItem   removeItem   addServiceLevelDiscount   removeServiceLevelDiscount   addItemLevelDiscount   removeItemLevelDiscount   addBillLevelDiscount   removeBillLevelDiscount   addProviderCoupons   removeProviderCoupons  addJaldeeCoupons   removeJaldeeCoupons   addDisplayNotes   addPrivateNotes
${self}         0
@{quantity}     1  2  3
${service_duration}   2
${parallel}           1
${DisplayName1}   item1_DisplayName



***Keywords***

Get Billable Subdomain
    [Arguments]   ${domain}  ${jsondata}  ${posval}  
    ${length}=  Get Length  ${jsondata.json()[${posval}]['subDomains']}
    FOR  ${pos}  IN RANGE  ${length}
            Set Suite Variable  ${subdomain}  ${jsondata.json()[${posval}]['subDomains'][${pos}]['subDomain']}
            ${resp}=   Get Sub Domain Settings    ${domain}    ${subdomain}
            Should Be Equal As Strings    ${resp.status_code}    200
            Exit For Loop IF  '${resp.json()['serviceBillable']}' == '${bool[1]}'
    END
    RETURN  ${subdomain}  ${resp.json()['serviceBillable']}


*** Test Cases ***

JD-TC-Get Bill By Id-1
    
    [Documentation]  Get bill Bill by UUId for valid Consumer

    ${PUSERPH0}=  Evaluate  ${PUSERNAME}+100100101
    Set Suite Variable   ${PUSERPH0}
    
    ${firstname}  ${lastname}  ${PhoneNumber}  ${PUSERPH0}=  Provider Signup  PhoneNumber=${PUSERPH0}
    ${resp}=  Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${PUSERPH0}

    Set Test Variable  ${email_id}  ${P_Email}${PUSERPH0}.${test_mail}

    ${GST_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}
    ${resp}=  Update Tax Percentage  ${gstpercentage[2]}  ${GST_num}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Tax
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    
    ${short_desc}=   FakerLibrary.sentence  nb_words=3
    Log  ${short_desc}
    ${long_desc}=   FakerLibrary.sentence
    Log  ${long_desc}
    ${item1}=     FakerLibrary.word
    ${itemCode1}=     FakerLibrary.word
    ${price1}=     Random Int   min=400   max=500
    ${price}=  Convert To Number  ${price1}  1
    # ${resp}=  Create Item   ${item1}  ${short_desc}  ${long_desc}  ${price}  ${bool[1]} 
    ${resp}=  Create Sample Item   ${DisplayName1}   ${item1}  ${itemCode1}  ${price}  ${bool[1]} 
    Log  ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${itemId}  ${resp.json()}
    
    ${resp}=  Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]} 

    ${resp}=  Get Bill Settings 
    Log   ${resp.json}
    IF  ${resp.status_code}!=200
        Log   Status code is not 200: ${resp.status_code}
        ${resp}=  Enable Disable bill  ${bool[1]}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    ELSE IF  ${resp.json()['enablepos']}==${bool[0]}
        ${resp}=  Enable Disable bill  ${bool[1]}
        Log   ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200
    END

    ${resp}=  Get Bill Settings 
    Log   ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Run Keyword And Continue On Failure  Should Be Equal As Strings  ${resp.json()['enablepos']}    ${bool[1]}


    ${discount1}=     FakerLibrary.word
    ${desc}=   FakerLibrary.word
    ${discountprice1}=     Random Int   min=50   max=100
    ${discountprice}=  Convert To Number  ${discountprice1}  1
    ${resp}=   Create Discount  ${discount1}   ${desc}    ${discountprice}   ${calctype[1]}  ${disctype[0]}
    Log  ${resp.json()}
    Set Suite Variable   ${discountId}   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  AddCustomer  ${CUSERNAME8}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}

    ${resp}=  GetCustomer  phoneNo-eq=${CUSERNAME8}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable  ${cid}  ${resp.json()[0]['id']}

    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  
    ${SERVICE1}=    FakerLibrary.word
    ${desc}=   FakerLibrary.sentence
    ${min_pre}=   Random Int   min=1   max=50
    ${serviceamt1}=   Random Int   min=500   max=1000
    ${serviceamt}=  Convert To Number  ${serviceamt1}  1
    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${service_duration}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${serviceamt}  ${bool[0]}  ${bool[1]}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${s_id1}  ${resp.json()}
    ${resp}=  Get Locations
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${tz}  ${resp.json()[0]['timezone']}
    ${list}=  Create List   1  2  3  4  5  6  7
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    ${eTime}=  add_timezone_time  ${tz}  0  30  
    ${queue1}=    FakerLibrary.word
    ${capacity}=  FakerLibrary.Numerify  %%%
    ${resp}=  Create Queue  ${queue1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${parallel}  ${capacity}  ${lid}  ${s_id1}
    Log  ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid1}  ${resp.json()}
    
    # ${resp}=  pyproviderlogin  ${PUSERPH0}  ${PASSWORD}
    # Should Be Equal As Strings  ${resp}  200      
    # @{resp}=  uploadLogoImages
    # Should Be Equal As Strings  ${resp[1]}  200
    # ${resp}=  Get GalleryOrlogo image  logo
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Should Be Equal As Strings  ${resp.json()[0]['prefix']}  logo

    ${coupon1}=    FakerLibrary.word
    ${desc}=  FakerLibrary.Sentence   nb_words=2
    ${coupenprice1}=     Random Int   min=50   max=100
    ${coupenprice}=  Convert To Number  ${coupenprice1}  1
    ${cupn_code}=   FakerLibrary.word
    Set Suite Variable   ${cupn_code}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  db.subtract_timezone_time  ${tz}  0  15
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    ${ST_DAY}=  db.get_date_by_timezone  ${tz}
    ${EN_DAY}=  db.add_timezone_date  ${tz}   10
    ${min_bill_amount}=   Random Int   min=100   max=1000
    ${max_disc_val}=   Random Int   min=100   max=500
    ${max_prov_use}=   Random Int   min=10   max=20
    ${book_channel}=   Create List   ${bookingChannel[0]}
    ${coupn_based}=  Create List   ${couponBasedOn[0]}
    ${tc}=  FakerLibrary.sentence
    ${services}=   Create list   ${s_id1} 
    ${items}=   Create List   ${itemId}
    ${resp}=  Create Provider Coupon   ${coupon1}  ${desc}  ${coupenprice}  ${calctype[1]}  ${cupn_code}  ${recurringtype[1]}  ${list}  ${sTime}  ${eTime}  ${ST_DAY}  ${EN_DAY}  ${EMPTY}  ${bool[1]}  ${min_bill_amount}  ${max_disc_val}  ${bool[1]}  ${max_prov_use}  ${book_channel}  ${coupn_based}  ${tc}  services=${services}  items=${items}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${couponId}  ${resp.json()}
    
    ${resp}=  Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[0]}

    ${fields}=   Get subDomain level Fields  ${d1}  ${sd1}
    Log  ${fields.json()}
    Should Be Equal As Strings    ${fields.status_code}   200
    ${virtual_fields}=  get_Subdomainfields  ${fields.json()}
    ${resp}=  Update Subdomain_Level  ${virtual_fields}  ${sd1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get specializations Sub Domain  ${d1}  ${sd1}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${spec}=  get_Specializations  ${resp.json()}
    ${resp}=  Update Specialization  ${spec}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}   

    ${pid0}=  get_acc_id  ${PUSERPH0}
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${pid0} 

    ${cmsg}=   FakerLibrary.sentence
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${resp}=  Add To Waitlist  ${cid}  ${s_id1}  ${qid1}  ${DAY1}  ${cmsg}  ${bool[1]}  ${cid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}

    ${resp}=  Get Bill By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${bid}  ${resp.json()['id']}

    ${itemreason}=   FakerLibrary.word
    ${item}=  Item Bill  ${itemreason}  ${itemId}  ${quantity[0]}
    ${resp}=  Update Bill   ${wid}  ${action[3]}  ${item}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    # ${coupon}=  Provider Coupons  ${bid}  ${couponId}
    ${resp}=  Update Bill   ${wid}  ${action[12]}  ${cupn_code}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${pnote}=   FakerLibrary.word
    ${dnote}=    FakerLibrary.word
    ${disc1}=  Bill Discount Input  ${discountId}  ${pnote}  ${dnote}
    ${bdisc}=  Bill Discount  ${bid}  ${disc1}   
    ${resp}=  Update Bill   ${wid}  ${action[10]}  ${bdisc}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${quantity}=  Convert To Number  ${quantity[0]}  1
    ${itemprice}=  Evaluate  ${quantity}*${price}
    ${nettotal1}=  Evaluate  ${itemprice}+${serviceamt}
    ${nettotal}=  Convert To Number  ${nettotal1}  1
    ${reducedisct}=  Evaluate  ${nettotal}-${discountprice}
    ${reducecoupen}=  Evaluate  ${reducedisct}-${coupenprice}
    ${taxtotal}=  Evaluate  ${reducecoupen}*${gstpercentage[2]}/100
    ${toataldue}=   Evaluate  ${taxtotal}+${reducecoupen}
    ${toataldue}=    roundoff    ${toataldue}


    ${resp}=  ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Consumer Login  ${CUSERNAME8}   ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200

    # ${resp}=  Get Bill By consumer  ${wid}  ${pid0} 
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get consumer Waitlist Bill Details   ${wid}  
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid}  netTotal=${nettotal}  billStatus=${billStatus[0]}  billViewStatus=${billViewStatus[1]}  netRate=${toataldue}  billPaymentStatus=NotPaid  totalAmountPaid=0.0  amountDue=${toataldue}  taxableTotal=${reducecoupen}  totalTaxAmount=${taxtotal}  taxPercentage=${gstpercentage[2]}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${s_id1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1}  
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   ${gstpercentage[2]} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  ${serviceamt}
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  ${serviceamt}
    Should Be Equal As Strings  ${resp.json()['items'][0]['itemId']}  ${itemId}  
    Should Be Equal As Strings  ${resp.json()['items'][0]['price']}  ${price}
    Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}  ${DisplayName1}  
    Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}  ${quantity}
    Should Be Equal As Strings  ${resp.json()['items'][0]['reason']}  ${itemreason}  
    Should Be Equal As Strings  ${resp.json()['items'][0]['GSTpercentage']}   ${gstpercentage[2]}
    Should Be Equal As Strings  ${resp.json()['discount'][0]['id']}  ${discountId}    
    Should Be Equal As Strings  ${resp.json()['discount'][0]['name']}  ${discount1} 
    Should Be Equal As Strings  ${resp.json()['discount'][0]['discValue']}  ${discountprice}  
    Should Be Equal As Strings  ${resp.json()['discount'][0]['displayNote']}  ${dnote}
    Should Be Equal As Strings  ${resp.json()['discount'][0]['privateNote']}  ${pnote}  
    Should Be Equal As Strings  ${resp.json()['discount'][0]['calculationType']}  ${calctype[1]}
    # Should Be Equal As Strings  ${resp.json()['providerCoupon'][0]['id']}  ${couponId}  
    # Should Be Equal As Strings  ${resp.json()['providerCoupon'][0]['couponValue']}  ${coupenprice} 
    # Should Be Equal As Strings  ${resp.json()['providerCoupon'][0]['name']}  ${coupon1}
    Should Be Equal As Strings  ${resp.json()['providerCoupon']['${cupn_code}']['value']}  ${coupenprice}  

JD-TC-Get Bill By Id-UH1

    [Documentation]  Get Bill by id  using another consumer uuid

    ${resp}=   Consumer Login  ${CUSERNAME9}   ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200
    # ${resp}=  Get Bill By consumer  ${wid}  ${pid0} 
    ${resp}=  Get consumer Waitlist Bill Details   ${wid}  
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${YOU_CANNOT_VIEW_THE_BILL}"

JD-TC-Get Bill By Id-UH2
    [Documentation]   get bill of another consumer through provider login
    ${resp}=   Encrypted Provider Login  ${PUSERNAME101}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200 
    # ${resp}=  Get Bill By consumer  ${wid}  ${pid0}
    ${resp}=  Get consumer Waitlist Bill Details   ${wid}  
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${NO_PERMISSION}"   

JD-TC-Get Bill By Id-UH3  
    [Documentation]   get bill without login      
    # ${resp}=  Get Bill By consumer  ${wid}  ${pid0}  
    ${resp}=  Get consumer Waitlist Bill Details   ${wid}  
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}" 

clear_queueand Waitlist
     clear_queue  ${PUSERNAME101}    
     clear_service  ${PUSERNAME101}