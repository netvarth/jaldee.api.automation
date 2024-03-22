*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Bill
Library           Collections
Library           String
Library           json
Library           requests
Library           FakerLibrary
Library           Process
Library           OperatingSystem
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/SuperAdminKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

 
*** Variables ***
${a}   10
${loc}  Location1
${SERVICE1}  SERVICE1
${SERVICE2}  SERVICE2
${SERVICE3}  SERVICE3
${SERVICE4}  SERVICE4
${queue1}  QUEUE1
${jcoupon1}   CouponMul00
${jcoupon2}   CouponMul01
${item}          Item1
${DisplayName1}   item1_DisplayName
${itemCode1}   ItemCode1
${numbers}  0123456789
@{service_duration}  10  20  30   40   50


*** Test Cases ***

JD-TC-BillJC-1

    [Documentation]   create bill with  JC applied
    clear_service       ${PUSERNAME152}
    clear_location   ${PUSERNAME152}
    clear_jaldeecoupon   ${jcoupon1}
    clear_jaldeecoupon   ${jcoupon2}
    clear_Item    ${PUSERNAME152}
    clear_customer   ${PUSERNAME152}
    ${firstname}=  FakerLibrary.name
    ${name1}=  FakerLibrary.name
    ${city}=   get_place
    ${IFSC}=  Generate_ifsc_code
    ${min_pre}=   FakerLibrary.pyfloat   left_digits=2   right_digits=2   positive=True
    ${Total}=   FakerLibrary.pyfloat   left_digits=3   right_digits=2   positive=True
    ${ph}=   evaluate    ${PUSERNAME152}+1234
    ${acc}=    Generate_random_value  11   ${numbers}
    ${notify}    Random Element     ['Current','Saving']
    ${notify1}    Random Element     ['True','False']
    ${companySuffix}=  FakerLibrary.companySuffix
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${tz}=   db.get_Timezone_by_lat_long   ${latti}  ${longi}
    Set Suite Variable  ${tz}
    ${description}=  FakerLibrary.sentence
    ${snote}=  FakerLibrary.Word
    ${dis}=  FakerLibrary.Word
    #${resp}=   ConsumerLogin  ${CUSERNAME9}  ${PASSWORD}
    #Set Suite Variable   ${cid}   ${resp.json()['id']}
    #Should Be Equal As Strings    ${resp.status_code}   200 
    #${resp}=  Consumer Logout
    #Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Test Variable  ${d1}  ${resp.json()['sector']}
    Set Test Variable  ${sd1}  ${resp.json()['subSector']}

    ${resp}=  Set jaldeeIntegration Settings    ${EMPTY}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}
    
    ${GST_num}   ${PAN_NUM}=  db.Generate_gst_number  ${Container_id}
    ${resp}=  Update Tax Percentage  18   ${GST_num} 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Tax
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=   Update Account Payment Settings   ${bool[0]}  ${bool[0]}  ${bool[1]}  ${ph}   ${PAN_NUM}   ${acc}   ${name1}   ${IFSC}   ${firstname}   ${firstname}   ${city}   Individual   ${notify}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${pid}=  get_acc_id  ${PUSERNAME152}
    Set Suite Variable  ${pid}
    ${resp}=  payuVerify  ${pid}
    ${resp}=   Update Account Payment Settings   ${bool[1]}  ${bool[0]}  ${bool[1]}  ${ph}   ${PAN_NUM}   ${acc}   ${name1}   ${IFSC}   ${firstname}   ${firstname}   ${city}   Individual   ${notify}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  SetMerchantId  ${pid}  4825051
    ${pid}=  get_acc_id   ${PUSERNAME152}
    Set Suite Variable  ${pid}

    ${resp}=  AddCustomer  ${CUSERNAME9}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${cid}  ${resp.json()}

    ${DAY}=  db.get_date_by_timezone  ${tz}   
    Set Suite Variable  ${DAY}
    ${resp}=  Create Service  ${SERVICE1}  ${description}   ${service_duration[2]}  ${status[0]}  ${btype}   ${bool[1]}   ${notifytype[2]}   ${EMPTY}  500  ${bool[0]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid1}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE2}  ${description}   ${service_duration[2]}  ${status[0]}  ${btype}   ${bool[1]}   ${notifytype[2]}   50  100  ${bool[1]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid2}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE3}  ${description}   ${service_duration[2]}  ${status[0]}  ${btype}   ${bool[1]}   ${notifytype[2]}   ${EMPTY}  500  ${bool[0]}  ${bool[0]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid3}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE4}  ${description}   ${service_duration[2]}  ${status[0]}  ${btype}   ${bool[1]}   ${notifytype[2]}   50  100  ${bool[1]}  ${bool[1]}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid4}  ${resp.json()}
    ${list}=  Create List  1  2  3  4  5  6  7
    ${sTime}=  add_timezone_time  ${tz}  0  30  
    ${eTime}=  add_timezone_time  ${tz}  2  00  
    ${resp}=  Create Location  ${loc}  ${longi}  ${latti}  www.${companySuffix}.com  ${postcode}   ${address}  free  True  Weekly  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid}  ${resp.json()}  
    ${list}=  Create List   1  2  3  4  5  6  7
    ${sTime}=  add_timezone_time  ${tz}  3  30  
    ${eTime}=  add_timezone_time  ${tz}  4  00  
    ${resp}=  Create Queue  ${queue1}  Weekly  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  1  100  ${lid}  ${sid1}  ${sid2}  ${sid3}  ${sid4}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${qid1}  ${resp.json()}
    ${resp}=  Get Queues
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Suite Variable  ${q1_l1}   ${resp.json()[0]['id']}
    ${resp}=   Get Active License
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}
    ${resp}=   ProviderLogout
    Should Be Equal As Strings    ${resp.status_code}    200
    ${domains}=  Jaldee Coupon Target Domains  ${d1}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}
    ${licenses}=  Jaldee Coupon Target License  ${lic1}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable  ${DAY1}  ${DAY1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Create Jaldee Coupon  ${jcoupon1}  ${dis}   ${dis}  CHILDREN  ${DAY1}  ${DAY2}  AMOUNT  50  100  ${bool[0]}  ${bool[0]}  100  100  1000  20  20  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${description}   ${snote}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Create Jaldee Coupon  ${jcoupon2}  ${dis}   ${dis}  CHILDREN  ${DAY1}  ${DAY2}  AMOUNT  50  100  ${bool[0]}  ${bool[0]}  100  100  1000  20  20  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[0]}  ${bool[1]}  ${description}  ${snote}  ${domains}  ${sub_domains}  ALL  ${licenses}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${jcoupon1}  ${description}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${jcoupon2}  ${description}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Enable Jaldee Coupon By Provider  ${jcoupon1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${jcoupon1} 
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ENABLED
    ${resp}=  Enable Jaldee Coupon By Provider  ${jcoupon2}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${jcoupon2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ENABLED
    ${resp}=  Add To Waitlist  ${cid}  ${sid1}  ${qid1}  ${DAY1}  hi  True  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid}  ${wid[0]}
    ${resp}=  Get Bill By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid}  netTotal=500.0  billStatus=New  billViewStatus=Notshow  netRate=590.0  billPaymentStatus=NotPaid  totalAmountPaid=0.0  amountDue=590.0  taxableTotal=500.0  totalTaxAmount=90.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sid1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   18.0 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  500.0
    ${resp}=  Apply Jaldee Coupon By Provider  ${jcoupon1}  ${wid}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
     Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid}  netTotal=500.0  billStatus=New  billViewStatus=Notshow  netRate=540.0  billPaymentStatus=NotPaid  totalAmountPaid=0.0  amountDue=540.0  taxableTotal=500.0  totalTaxAmount=90.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sid1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   18.0 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  500.0
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${jcoupon1}']['value']}  50.0
    Should Contain  ${resp.json()['jCoupon']['${jcoupon1}']['systemNote']}  COUPON_APPLIED



JD-TC-BillJC-2

    [Documentation]    Add one more service to a bill in which jc is applied
    ${snote}=  FakerLibrary.Word
    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${service}=  Service Bill  ${snote}   ${sId2}  1 
    ${resp}=  Update Bill   ${wid}  addService   ${service}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid}  netTotal=600.0  billStatus=New  billViewStatus=Notshow  netRate=658.0  billPaymentStatus=NotPaid  totalAmountPaid=0.0  amountDue=658.0  taxableTotal=600.0  totalTaxAmount=108.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sid1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   18.0 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][1]['serviceId']}  ${sid2}
    Should Be Equal As Strings  ${resp.json()['service'][1]['serviceName']}  ${SERVICE2} 
    Should Be Equal As Strings  ${resp.json()['service'][1]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['service'][1]['GSTpercentage']}   18.0 
    Should Be Equal As Strings  ${resp.json()['service'][1]['price']}  100.0
    Should Be Equal As Strings  ${resp.json()['service'][1]['netRate']}  100.0
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${jcoupon1}']['value']}  50.0
    Should Contain  ${resp.json()['jCoupon']['${jcoupon1}']['systemNote']}  COUPON_APPLIED




JD-TC-BillJC-3

    [Documentation]   Remove one service from a bill in which jc is applied 
    ${snote}=  FakerLibrary.Word
    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${service}=  Service Bill  ${snote}  ${sid1}  1 
    ${resp}=  Update Bill   ${wid}  removeService   ${service}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid}  netTotal=100.0  billStatus=New  billViewStatus=Notshow  netRate=68.0  billPaymentStatus=NotPaid  totalAmountPaid=0.0  amountDue=68.0  taxableTotal=100.0  totalTaxAmount=18.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sid2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE2} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   18.0 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  100.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  100.0
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${jcoupon1}']['value']}  50.0
    Should Contain  ${resp.json()['jCoupon']['${jcoupon1}']['systemNote']}  COUPON_APPLIED

JD-TC-BillJC-4

    [Documentation]    adjust service on a bill in which jc is applied 
    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${service}=  Service Bill  service forme  ${sid2}  3 
    ${resp}=  Update Bill   ${wid}  adjustService   ${service}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid}  netTotal=300.0  billStatus=New  billViewStatus=Notshow  netRate=304.0  billPaymentStatus=NotPaid  totalAmountPaid=0.0  amountDue=304.0  taxableTotal=300.0  totalTaxAmount=54.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sid2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE2} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  3.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   18.0 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  100.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  300.0
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${jcoupon1}']['value']}  50.0
    Should Contain  ${resp.json()['jCoupon']['${jcoupon1}']['systemNote']}  COUPON_APPLIED

JD-TC-BillJC-5

    [Documentation]   add item to a bill in which jc is applied
    ${description}=  FakerLibrary.sentence
    ${snote}=  FakerLibrary.Word
    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200

    # ${resp}=  Create Item   ${item}  ${snote}  ${description}  100  True 
    ${resp}=  Create Sample Item   ${DisplayName1}   ${item}  ${itemCode1}  100  ${bool[1]}  
    Should Be Equal As Strings  ${resp.status_code}   200
    Set Suite Variable  ${itemId}  ${resp.json()}
    ${additem}=  Item Bill with Price   ${snote}  ${itemId}  1   50
    ${resp}=  Update Bill   ${wid}  addItem   ${additem}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid}  netTotal=350.0  billStatus=New  billViewStatus=Notshow  netRate=363.0  billPaymentStatus=NotPaid  totalAmountPaid=0.0  amountDue=363.0  taxableTotal=350.0  totalTaxAmount=63.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sid2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE2} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  3.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   18.0 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  100.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  300.0
    Should Be Equal As Strings  ${resp.json()['items'][0]['itemId']}  ${itemId}  
    Should Be Equal As Strings  ${resp.json()['items'][0]['price']}  50.0
    Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}  ${DisplayName1}
    Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['items'][0]['GSTpercentage']}   18.0 
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${jcoupon1}']['value']}  50.0
    Should Contain  ${resp.json()['jCoupon']['${jcoupon1}']['systemNote']}  COUPON_APPLIED


JD-TC-BillJC-6

    [Documentation]   Remove item from a bill in which jc is applied
    ${snote}=  FakerLibrary.Word
    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${ritem}=  Item Bill  ${snote}  ${itemId}  1
    ${resp}=  Update Bill   ${wid}  removeItem   ${ritem}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid}  netTotal=300.0  billStatus=New  billViewStatus=Notshow  netRate=304.0  billPaymentStatus=NotPaid  totalAmountPaid=0.0  amountDue=304.0  taxableTotal=300.0  totalTaxAmount=54.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sid2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE2} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  3.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   18.0 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  100.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  300.0
    Should Not Contain  ${resp.json()}  itemId
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${jcoupon1}']['value']}  50.0
    Should Contain  ${resp.json()['jCoupon']['${jcoupon1}']['systemNote']}  COUPON_APPLIED



JD-TC-BillJC-7

    [Documentation]   adjust item on a bill in which jc is applied 
    ${snote}=  FakerLibrary.Word
    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${aitem}=  Item Bill  ${snote}  ${itemId}  2
    ${resp}=  Update Bill   ${wid}  adjustItem   ${aitem}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid}  netTotal=500.0  billStatus=New  billViewStatus=Notshow  netRate=540.0  billPaymentStatus=NotPaid  totalAmountPaid=0.0  amountDue=540.0  taxableTotal=500.0  totalTaxAmount=90.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sid2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE2} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  3.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   18.0 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  100.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  300.0
    Should Be Equal As Strings  ${resp.json()['items'][0]['itemId']}  ${itemId}  
    Should Be Equal As Strings  ${resp.json()['items'][0]['price']}  100.0
    Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}  ${DisplayName1}
    Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}  2.0
    Should Be Equal As Strings  ${resp.json()['items'][0]['GSTpercentage']}   18.0 
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${jcoupon1}']['value']}  50.0
    Should Contain  ${resp.json()['jCoupon']['${jcoupon1}']['systemNote']}  COUPON_APPLIED



JD-TC-BillJC-8

    [Documentation]    Remove one auantity of item from a bill(2 is there) in which jc is applied
    ${snote}=  FakerLibrary.Word
    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${ritem}=  Item Bill  ${snote}  ${itemId}  1
    ${resp}=  Update Bill   ${wid}  adjustItem   ${ritem}
    Should Be Equal As Strings  ${resp.status_code}  200
     ${resp}=  Get Bill By UUId  ${wid}
     Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid}  netTotal=400.0  billStatus=New  billViewStatus=Notshow  netRate=422.0  billPaymentStatus=NotPaid  totalAmountPaid=0.0  amountDue=422.0  taxableTotal=400.0  totalTaxAmount=72.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sid2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE2} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  3.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   18.0 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  100.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  300.0
    Should Be Equal As Strings  ${resp.json()['items'][0]['itemId']}  ${itemId}  
    Should Be Equal As Strings  ${resp.json()['items'][0]['price']}  100.0
    Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}  ${DisplayName1}
    Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['items'][0]['GSTpercentage']}   18.0 
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${jcoupon1}']['value']}  50.0
    Should Contain  ${resp.json()['jCoupon']['${jcoupon1}']['systemNote']}  COUPON_APPLIED


JD-TC-BillJC-9

    [Documentation]  Remove one quantity of a service from a bill(3 is there) in which jc is applied 
    ${snote}=  FakerLibrary.Word
    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${service}=  Service Bill  ${snote}  ${sid2}  2
    ${resp}=  Update Bill   ${wid}  adjustService   ${service}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid}  netTotal=300.0  billStatus=New  billViewStatus=Notshow  netRate=304.0  billPaymentStatus=NotPaid  totalAmountPaid=0.0  amountDue=304.0  taxableTotal=300.0  totalTaxAmount=54.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sid2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE2} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  2.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   18.0 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  100.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  200.0
    Should Be Equal As Strings  ${resp.json()['items'][0]['itemId']}  ${itemId}  
    Should Be Equal As Strings  ${resp.json()['items'][0]['price']}  100.0
    Should Be Equal As Strings  ${resp.json()['items'][0]['itemName']}  ${DisplayName1}
    Should Be Equal As Strings  ${resp.json()['items'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['items'][0]['GSTpercentage']}   18.0 
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${jcoupon1}']['value']}  50.0
    Should Contain  ${resp.json()['jCoupon']['${jcoupon1}']['systemNote']}  COUPON_APPLIED


JD-TC-BillJC-10

    [Documentation]   Remove all services,items and add new service to bill where jc is applied
    ${snote}=  FakerLibrary.Word
    ${resp}=  Encrypted Provider Login  ${PUSERNAME152}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${service}=  Service Bill   ${snote}   ${sid2}  1 
    ${resp}=  Update Bill   ${wid}  removeService   ${service}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${ritem}=  Item Bill   ${snote}   ${itemId}  1
    ${resp}=  Update Bill   ${wid}  removeItem   ${ritem}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${service}=  Service Bill  service forme  ${sid3}  2
    ${resp}=  Update Bill   ${wid}  addService   ${service}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid}  netTotal=1000.0  billStatus=New  billViewStatus=Notshow  netRate=950.0  billPaymentStatus=NotPaid  totalAmountPaid=0.0  amountDue=950.0  taxableTotal=0.0  totalTaxAmount=0.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sid3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE3} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  2.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   0.0 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  1000.0
    Should Not Contain  ${resp.json()}  itemId
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${jcoupon1}']['value']}  50.0
    Should Contain  ${resp.json()['jCoupon']['${jcoupon1}']['systemNote']}  COUPON_APPLIED



