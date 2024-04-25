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
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py
Variables         /ebs/TDD/varfiles/consumermail.py
 

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
    Append To File  ${EXECDIR}/data/TDD_Logs/numbers.txt  ${PUSERPH0}${\n}
    Set Suite Variable   ${PUSERPH0}
    ${resp}=   Run Keywords  clear_queue  ${PUSERPH0}  AND  clear_service  ${PUSERPH0}  AND  clear_Item    ${PUSERPH0}  AND   clear_Coupon   ${PUSERPH0}   AND  clear_Discount  ${PUSERPH0}
    ${licid}  ${licname}=  get_highest_license_pkg
    Log  ${licid}
    Log  ${licname}
    ${domresp}=  Get BusinessDomainsConf
    Log   ${domresp.json()}
    Should Be Equal As Strings  ${domresp.status_code}  200
    ${dlen}=  Get Length  ${domresp.json()}
    FOR  ${pos}  IN RANGE  ${dlen}  
        Set Suite Variable  ${d1}  ${domresp.json()[${pos}]['domain']}
        ${sd1}  ${check}=  Get Billable Subdomain  ${d1}  ${domresp}  ${pos}  
        Set Suite Variable   ${sd1}
        Exit For Loop IF     '${check}' == '${bool[1]}'
    END
    Log  ${d1}
    Log  ${sd1}

    ${firstname}=  FakerLibrary.first_name
    ${lastname}=  FakerLibrary.last_name
    ${address}=  FakerLibrary.address
    ${dob}=  FakerLibrary.Date
    ${gender}    Random Element    ${Genderlist}
    ${resp}=  Account SignUp  ${firstname}  ${lastname}  ${None}  ${d1}  ${sd1}  ${PUSERPH0}  ${licid}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=  Account Activation  ${PUSERPH0}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  "${resp.json()}"    "true"
    
    ${resp}=  Account Set Credential  ${PUSERPH0}  ${PASSWORD}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    ${resp}=   Encrypted Provider Login  ${PUSERPH0}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${decrypted_data}=  db.decrypt_data  ${resp.content}
    Log  ${decrypted_data}
    Set Suite Variable  ${pid}  ${decrypted_data['id']}
    # Set Test Variable  ${pid}  ${resp.json()['id']}
    clear_customer   ${PUSERPH0}
    
    
    ${list}=  Create List  1  2  3  4  5  6  7
    Set Suite Variable  ${list}  ${list}
    @{Views}=  Create List  self  all  customersOnly
    ${ph1}=  Evaluate  ${PUSERPH0}+1000000000
    ${ph2}=  Evaluate  ${PUSERPH0}+2000000000
    ${views}=  Evaluate  random.choice($Views)  random
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  Phone Numbers  ${name1}  PhoneNo  ${ph1}  ${views}
    ${ph_nos2}=  Phone Numbers  ${name2}  PhoneNo  ${ph2}  ${views}
    ${emails1}=  Emails  ${name3}  Email  ${P_Email}101.${test_mail}  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ['True','False']
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${sTime}=  add_timezone_time  ${tz}  0  15  
    Set Suite Variable   ${sTime}
    ${eTime}=  add_timezone_time  ${tz}  0  45  
    Set Suite Variable   ${eTime}
    ${resp}=  Update Business Profile with Schedule    ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${24hours}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}   ${EMPTY}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    Set Test Variable  ${email_id}  ${P_Email}${PUSERPH0}.${test_mail}

    ${resp}=  Update Email   ${p_id}   ${firstname}   ${lastname}   ${email_id}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    
    sleep   01s

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
    
    # ${coupon1}=   FakerLibrary.word
    # ${desc}=   FakerLibrary.word
    # ${coupenprice1}=     Random Int   min=50   max=100
    # ${coupenprice}=  Convert To Number  ${coupenprice1}  1
    # ${resp}=  Create Coupon  ${coupon1}  ${desc}  ${coupenprice}  ${calctype[1]}
    # Log  ${resp.json()}
    # Should Be Equal As Strings  ${resp.status_code}  200
    # Set Suite Variable   ${couponId}   ${resp.json()} 
    
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

    ${resp}=  Get Locations
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${lid}  ${resp.json()[0]['id']}
    Set Suite Variable  ${tz}  ${resp.json()[0]['bSchedule']['timespec'][0]['timezone']}

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

    ${resp}=  Get Bill By consumer  ${wid}  ${pid0} 
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
    ${resp}=  Get Bill By consumer  ${wid}  ${pid0} 
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${YOU_CANNOT_VIEW_THE_BILL}"

JD-TC-Get Bill By Id-UH2
    [Documentation]   get bill of another consumer through provider login
    ${resp}=   Encrypted Provider Login  ${PUSERNAME101}  ${PASSWORD} 
    Should Be Equal As Strings    ${resp.status_code}   200 
    ${resp}=  Get Bill By consumer  ${wid}  ${pid0}
    Should Be Equal As Strings  ${resp.status_code}  401
    Should Be Equal As Strings  "${resp.json()}"  "${YOU_CANNOT_VIEW_THE_BILL}"   

JD-TC-Get Bill By Id-UH3  
    [Documentation]   get bill without login      
    ${resp}=  Get Bill By consumer  ${wid}  ${pid0}  
    Should Be Equal As Strings  ${resp.status_code}  419
    Should Be Equal As Strings  "${resp.json()}"  "${SESSION_EXPIRED}" 

clear_queueand Waitlist
     clear_queue  ${PUSERNAME101}    
     clear_service  ${PUSERNAME101}