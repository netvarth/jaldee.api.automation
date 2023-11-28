*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Bill
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Resource          /ebs/TDD/superadminkeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py

*** Variables ***
${sTime}        08:21 AM
${eTime}   	    08:51 PM
${loc}          MND
${longi}        29.524721
${latti}        88.259821
${LsTime}       08:00 AM 
${LeTime}       08:05 AM
${SERVICE1}   FacialBody4323
${SERVICE2}   MakeupHair5315
${SERVICE3}   CutHairstylingHair35
${SERVICE4}   Colouring46
${coupon}   MulOnam
${item}   MulQWERTY
${item1}  MulHJKL
${discount}  Mulsoap
${jcoupon1}   CouponMul00
${jcoupon2}   CouponMul01
${coupon}   Mulcoupon

*** Test Cases ***
JD-TC-Checkin and Bill-1
	Comment  create bill when parent cancel the waitlist and the bill is created to a member
    ${resp}=  Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Update Account Payment Settings   False  False  True  1888888888   ABCDE1234G  101010101010  icicbank  IFCcodd11234  BIJU  BIJU  Trissur  Individual  Saving   
    Should Be Equal As Strings    ${resp.status_code}   200
    ${pid}=  get_acc_id  ${PUSERNAME6}
    Set Suite Variable  ${pid}
    ${resp}=  payuVerify  ${pid}
    ${resp}=   Update Account Payment Settings   True  False  True  1888888888   ABCDE1234G  101010101010  icicbank  IFCcodd11234  BIJU  BIJU  Trissur  Individual  Saving   
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  SetMerchantId  ${pid}  4825051
    ${pid}=  get_acc_id  ${PUSERNAME6}
    Set Suite Variable  ${pid}
    ${DAY}=  db.get_date_by_timezone  ${tz}   
    Set Suite Variable  ${DAY} 
    ${resp}=  Update Tax Percentage  12  12DEFBV1100M2Z5 
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Tax
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Create Service  ${SERVICE1}  Description   5  ACTIVE  Waitlist  True  email  ${EMPTY}  500  False  False
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sId_1}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE2}  Description   5  ACTIVE  Waitlist  True  email  ${EMPTY}  200  False  True
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sId_2}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE3}  Description   5  ACTIVE  Waitlist  True  email  ${EMPTY}  300  False  False
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sId_3}  ${resp.json()}
    ${resp}=  Create Service  ${SERVICE4}  Description   5  ACTIVE  Waitlist  True  email  ${EMPTY}  100  False  True
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sId_4}  ${resp.json()}
    sleep  2s
    ${list}=  Create List  1  2  3  4  5  6  7
    ${resp}=  Create Location  ${loc}  ${longi}  ${latti}  www.sampleurl.com  680030  Palliyil House  free  True  Weekly  ${list}  ${DAY}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${lid1}  ${resp.json()}  
    Sleep  4s
    ${resp}=  Get Queues
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Suite Variable  ${q1_l1}   ${resp.json()[0]['id']}
    ${resp}=   Get Active License
    Should Be Equal As Strings    ${resp.status_code}   200
    Set Suite Variable  ${lic1}  ${resp.json()['accountLicense']['licPkgOrAddonId']}

    ${resp}=  Get Search Status
	Run Keyword If  '${resp.json()}'=='false'   Enable Search Data
    ${resp}=   ProviderLogout
    Should Be Equal As Strings  ${resp.status_code}    200

    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${d1}  ${resp.json()[0]['domain']}
    Set Test Variable  ${d2}  ${resp.json()[1]['domain']}
    Set Test Variable  ${sd1}  ${resp.json()[0]['subDomains'][0]['subDomain']}
    Set Test Variable  ${sd2}  ${resp.json()[0]['subDomains'][1]['subDomain']}
    Set Test Variable  ${sd3}  ${resp.json()[1]['subDomains'][0]['subDomain']}
    Set Test Variable  ${sd4}  ${resp.json()[1]['subDomains'][1]['subDomain']}
    ${domains}=  Jaldee Coupon Target Domains  ${d1}  ${d2}
    ${sub_domains}=  Jaldee Coupon Target SubDomains  ${d1}_${sd1}  ${d1}_${sd2}  ${d2}_${sd3}  ${d2}_${sd4}
    ${licenses}=  Jaldee Coupon Target License  ${lic1}
    ${DAY2}=  db.add_timezone_date  ${tz}  10  
    Set Suite Variable  ${DAY2}  ${DAY2}
    ${resp}=  SuperAdmin Login  ${SUSERNAME}  ${SPASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Create Jaldee Coupon  ${jcoupon1}  Onam Coupon  Onam offer  CHILDREN  ${DAY}  ${DAY2}  PERCENTAGE  20  100  false  false  100  100  1000  20  20  false  false  false  false  true  consumer first use  50% offer  ${domains}  ${sub_domains}  ALL  ${licenses}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Create Jaldee Coupon  ${jcoupon2}  Onam Coupon  Onam offer  CHILDREN  ${DAY}  ${DAY2}  PERCENTAGE  20  600  false  false  100  600  1000  20  20  false  false  false  false  true  consumer first use  50% offer  ${domains}  ${sub_domains}  ALL  ${licenses}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${jcoupon1}  Onam Coupon Offer
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Push Jaldee Coupon  ${jcoupon2}  Onam Coupon Offer
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  SuperAdmin Logout
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=   Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${resp}=  Enable Jaldee Coupon By Provider  ${jcoupon1}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Jaldee Coupons By Coupon_code  ${jcoupon1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['couponState']}  ENABLED
    
    ${coupons}=  Create List  ${jcoupon1}

    ${resp}=  Consumer Login  ${CUSERNAME}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200     
    ${cid}=  get_id  ${CUSERNAME}    
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${q1_l1}  ${DAY}  ${sId_1}  i need  False  ${coupons}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid1}  ${wid[0]}
    ${resp}=  Consumer Logout
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Consumer Login  ${CUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200     
    ${cid}=  get_id  ${CUSERNAME1}    
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${q1_l1}  ${DAY}  ${sId_1}  i need  False  ${coupons}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid2}  ${wid[0]}
    ${resp}=  Consumer Logout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200     
    ${cid}=  get_id  ${CUSERNAME2}    
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${q1_l1}  ${DAY}  ${sId_1}  i need  False  ${coupons}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid3}  ${wid[0]}
    ${resp}=  Consumer Logout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME3}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200     
    ${cid}=  get_id  ${CUSERNAME3}    
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${q1_l1}  ${DAY}  ${sId_2}  i need  False  ${coupons}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid4}  ${wid[0]}
    ${resp}=  Consumer Logout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME4}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200     
    ${cid}=  get_id  ${CUSERNAME4}    
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${q1_l1}  ${DAY}  ${sId_2}  i need  False  ${coupons}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid5}  ${wid[0]}
    ${resp}=  Consumer Logout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${CUSERNAME5}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200     
    ${cid}=  get_id  ${CUSERNAME5}    
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${q1_l1}  ${DAY}  ${sId_2}  i need  False  ${coupons}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid6}  ${wid[0]}
    ${resp}=  Consumer Logout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${GIN_CUSERNAME}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200     
    ${cid}=  get_id  ${GIN_CUSERNAME}   
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${q1_l1}  ${DAY}  ${sId_3}  i need  False  ${coupons}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid7}  ${wid[0]}
    ${resp}=  Consumer Logout
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Consumer Login  ${PUSERNAME}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200     
    ${cid}=  get_id  ${PUSERNAME}    
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${q1_l1}  ${DAY}  ${sId_3}  i need  False  ${coupons}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid8}  ${wid[0]}
    ${resp}=  Consumer Logout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${PUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200     
    ${cid}=  get_id  ${PUSERNAME1}    
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${q1_l1}  ${DAY}  ${sId_3}  i need  False  ${coupons}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid9}  ${wid[0]}
    ${resp}=  Consumer Logout
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Consumer Login  ${PUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200     
    ${cid}=  get_id  ${PUSERNAME2}    
    ${resp}=  Add To Waitlist Consumers with JCoupon  ${pid}  ${q1_l1}  ${DAY}  ${sId_4}  i need  False  ${coupons}  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200 
    
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Suite Variable  ${wid10}  ${wid[0]}
    ${resp}=  Consumer Logout
    Should Be Equal As Strings  ${resp.status_code}  200

    change_system_date  1

    ${resp}=  Encrypted Provider Login  ${PUSERNAME6}  ${PASSWORD}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Waitlist Action  REPORT  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Waitlist Action  REPORT  ${wid4}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Waitlist Action  REPORT  ${wid7}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Waitlist Action  REPORT  ${wid10}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Waitlist Action  STARTED  ${wid2}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Waitlist Action  STARTED  ${wid5}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Waitlist Action  STARTED  ${wid8}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Waitlist Action  DONE  ${wid8}
    Should Be Equal As Strings  ${resp.status_code}  200

    Comment  Report1 create bill
    ${resp}=  Get Bill By UUId  ${wid1}
    Should Be Equal As Strings  ${resp.status_code}  200 

    Verify Response  ${resp}  uuid=${wid1}  netTotal=500.0  billStatus=New  billViewStatus=Notshow  netRate=400.0  billPaymentStatus=NotPaid  totalAmountPaid=0.0  amountDue=400.0  taxableTotal=0.0  totalTaxAmount=0.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sId_1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   0.0 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  500.0
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${jcoupon1}']['value']}  100.0
    Should Contain  ${resp.json()['jCoupon']['${jcoupon1}']['systemNote']}  COUPON_APPLIED


    Comment  Report2 change to checkin and create bill
    ${resp}=  Waitlist Action  CHECK_IN  ${wid4}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid4}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  uuid=${wid4}  netTotal=200.0  billStatus=New  billViewStatus=Notshow  netRate=184.0  billPaymentStatus=NotPaid  totalAmountPaid=0.0  amountDue=184.0  taxableTotal=200.0  totalTaxAmount=24.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sId_2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE2} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   12.0 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  200.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  200.0
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${jcoupon1}']['value']}  40.0
    Should Contain  ${resp.json()['jCoupon']['${jcoupon1}']['systemNote']}  COUPON_APPLIED


    Comment  Report3 change to start and create bill
    ${resp}=  Waitlist Action  STARTED  ${wid7}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid7}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  uuid=${wid7}  netTotal=300.0  billStatus=New  billViewStatus=Notshow  netRate=240.0  billPaymentStatus=NotPaid  totalAmountPaid=0.0  amountDue=240.0  taxableTotal=0.0  totalTaxAmount=0.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sId_3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE3} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   0.0 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  300.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  300.0
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${jcoupon1}']['value']}  60.0
    Should Contain  ${resp.json()['jCoupon']['${jcoupon1}']['systemNote']}  COUPON_APPLIED

    Comment  Report4  change to Done and create bill
    ${resp}=  Waitlist Action  STARTED  ${wid10}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Waitlist Action  DONE  ${wid10}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid10}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  uuid=${wid10}  netTotal=100.0  billStatus=New  billViewStatus=Notshow  netRate=92.0  billPaymentStatus=NotPaid  totalAmountPaid=0.0  amountDue=92.0  taxableTotal=100.0  totalTaxAmount=12.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sId_4}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE4} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   12.0 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  100.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  100.0
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${jcoupon1}']['value']}  20.0
    Should Contain  ${resp.json()['jCoupon']['${jcoupon1}']['systemNote']}  COUPON_APPLIED


    Comment  Checkin1 create bill
    ${resp}=  Get Bill By UUId  ${wid3}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  uuid=${wid3}  netTotal=500.0  billStatus=New  billViewStatus=Notshow  netRate=400.0  billPaymentStatus=NotPaid  totalAmountPaid=0.0  amountDue=400.0  taxableTotal=0.0  totalTaxAmount=0.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sId_1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   0.0 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  500.0
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${jcoupon1}']['value']}  100.0
    Should Contain  ${resp.json()['jCoupon']['${jcoupon1}']['systemNote']}  COUPON_APPLIED

    Comment  Checkin2 change to start and create bill
    ${resp}=  Waitlist Action  STARTED  ${wid6}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid6}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  uuid=${wid6}  netTotal=200.0  billStatus=New  billViewStatus=Notshow  netRate=184.0  billPaymentStatus=NotPaid  totalAmountPaid=0.0  amountDue=184.0  taxableTotal=200.0  totalTaxAmount=24.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sId_2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE2} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   12.0 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  200.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  200.0
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${jcoupon1}']['value']}  40.0
    Should Contain  ${resp.json()['jCoupon']['${jcoupon1}']['systemNote']}  COUPON_APPLIED

    Comment  Checkin3 change state Done and  create bill
    ${resp}=  Waitlist Action  STARTED  ${wid9}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Waitlist Action  DONE  ${wid9}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid9}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  uuid=${wid9}  netTotal=300.0  billStatus=New  billViewStatus=Notshow  netRate=240.0  billPaymentStatus=NotPaid  totalAmountPaid=0.0  amountDue=240.0  taxableTotal=0.0  totalTaxAmount=0.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sId_3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE3} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   0.0 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  300.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  300.0
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${jcoupon1}']['value']}  60.0
    Should Contain  ${resp.json()['jCoupon']['${jcoupon1}']['systemNote']}  COUPON_APPLIED


    Comment  Start1 create bill
    ${resp}=  Get Bill By UUId  ${wid2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid2}  netTotal=500.0  billStatus=New  billViewStatus=Notshow  netRate=400.0  billPaymentStatus=NotPaid  totalAmountPaid=0.0  amountDue=400.0  taxableTotal=0.0  totalTaxAmount=0.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sId_1}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE1} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   0.0 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  500.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  500.0
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${jcoupon1}']['value']}  100.0
    Should Contain  ${resp.json()['jCoupon']['${jcoupon1}']['systemNote']}  COUPON_APPLIED

    Comment  Start2 change state Done and  create bill
    ${resp}=  Waitlist Action  DONE  ${wid5}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get Bill By UUId  ${wid5}
    Should Be Equal As Strings  ${resp.status_code}  200 
    Verify Response  ${resp}  uuid=${wid5}  netTotal=200.0  billStatus=New  billViewStatus=Notshow  netRate=184.0  billPaymentStatus=NotPaid  totalAmountPaid=0.0  amountDue=184.0  taxableTotal=200.0  totalTaxAmount=24.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sId_2}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE2} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   12.0 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  200.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  200.0
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${jcoupon1}']['value']}  40.0
    Should Contain  ${resp.json()['jCoupon']['${jcoupon1}']['systemNote']}  COUPON_APPLIED
    

    Comment  Done1 create bill
    ${resp}=  Get Bill By UUId  ${wid8}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  uuid=${wid8}  netTotal=300.0  billStatus=New  billViewStatus=Notshow  netRate=240.0  billPaymentStatus=NotPaid  totalAmountPaid=0.0  amountDue=240.0  taxableTotal=0.0  totalTaxAmount=0.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceId']}  ${sId_3}
    Should Be Equal As Strings  ${resp.json()['service'][0]['serviceName']}  ${SERVICE3} 
    Should Be Equal As Strings  ${resp.json()['service'][0]['quantity']}  1.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['GSTpercentage']}   0.0 
    Should Be Equal As Strings  ${resp.json()['service'][0]['price']}  300.0
    Should Be Equal As Strings  ${resp.json()['service'][0]['netRate']}  300.0
    Should Be Equal As Strings  ${resp.json()['jCoupon']['${jcoupon1}']['value']}  60.0
    Should Contain  ${resp.json()['jCoupon']['${jcoupon1}']['systemNote']}  COUPON_APPLIED
