*** Settings ***

Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        Finance Manager
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Library           /ebs/TDD/db.py
Library           /ebs/TDD/excelfuncs.py
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 
Variables         /ebs/TDD/varfiles/hl_providers.py

*** Variables ***

@{service_names}

${service_duration}     30
${DisplayName1}   item1_DisplayName



*** Test Cases ***

JD-TC-Apply Item Level Discount-1

    [Documentation]  Apply Item  Level Discount.

    ${firstname}  ${lastname}  ${PUSERPH30}  ${LoginId}=  Provider Signup
    Set Suite Variable  ${PUSERPH30}

    ${resp}=  Enable Waitlist
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    sleep   01s
    
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[0]}   

    ${resp}=  Set jaldeeIntegration Settings    ${boolean[1]}  ${boolean[1]}  ${boolean[0]}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  Get jaldeeIntegration Settings
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['onlinePresence']}   ${bool[1]}

    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200


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



    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    IF  ${resp.json()['enableJaldeeFinance']}==${bool[0]}
        ${resp1}=    Enable Disable Jaldee Finance   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableJaldeeFinance']}  ${bool[1]}

    ${resp}=  Create Sample Location  
    Set Suite Variable    ${lid}    ${resp}  

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}


    ${name1}=   FakerLibrary.word
    Set Suite Variable   ${name1}
    ${resp}=  Create Category   ${name1}  ${categoryType[3]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${category_id2}   ${resp.json()}

    ${vender_name}=   FakerLibrary.firstname
    ${contactPersonName}=   FakerLibrary.lastname
    ${owner_name}=   FakerLibrary.lastname
    ${vendorId}=   FakerLibrary.word
    ${PO_Number}    Generate random string    5    123456789
    ${vendor_phno}=  Evaluate  ${PUSERNAME}+${PO_Number}
    ${vendor_phno}=  Create Dictionary  countryCode=${countryCodes[0]}   number=${vendor_phno}
    Set Test Variable  ${email}  ${vender_name}.${test_mail}
    ${address}=  FakerLibrary.city
    Set Suite Variable  ${address}
    ${bank_accno}=   db.Generate_random_value  size=11   chars=${digits} 
    ${branch}=   db.get_place
    ${ifsc_code}=   db.Generate_ifsc_code
    # ${gst_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}

    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc

    ${state}=    Evaluate     "${state}".title()
    ${state}=    String.RemoveString  ${state}    ${SPACE}
    Set Suite Variable    ${state}
    Set Suite Variable    ${district}
    Set Suite Variable    ${pin}
    ${vendor_phno}=   Create List  ${vendor_phno}
    Set Suite Variable    ${vendor_phno}
    
    ${email}=   Create List  ${email}
    Set Suite Variable    ${email}

    ${bankIfsc}    Random Number 	digits=5 
    ${bankIfsc}=    Evaluate    f'{${bankIfsc}:0>7d}'
    Log  ${bankIfsc}
    Set Suite Variable  ${bankIfsc}  55555${bankIfsc} 

    ${bankName}     FakerLibrary.name
    Set Suite Variable    ${bankName}

    ${upiId}     FakerLibrary.name
    Set Suite Variable  ${upiId}

    ${pan}    Random Number 	digits=5 
    ${pan}=    Evaluate    f'{${pan}:0>5d}'
    Log  ${pan}
    Set Suite Variable  ${pan}  55555${pan}

    ${branchName}=    FakerLibrary.name
    Set Suite Variable  ${branchName}
    ${gstin}    Random Number 	digits=5 
    ${gstin}=    Evaluate    f'{${gstin}:0>8d}'
    Log  ${gstin}
    Set Suite Variable  ${gstin}  55555${gstin}
    
    ${preferredPaymentMode}=    Create List    ${jaldeePaymentmode[0]}
    ${bankInfo}=    Create Dictionary     bankaccountNo=${bank_accno}    ifscCode=${bankIfsc}    bankName=${bankName}    upiId=${upiId}     branchName=${branchName}    pancardNo=${pan}    gstNumber=${gstin}    preferredPaymentMode=${preferredPaymentMode}    lastPaymentModeUsed=${jaldeePaymentmode[0]}
    ${bankInfo}=    Create List         ${bankInfo}


    ${resp1}=  AddCustomer  ${CUSERNAME11}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Set Suite Variable  ${pcid18}   ${resp1.json()}


    ${providerConsumerIdList}=  Create List  ${pcid18}
    Set Suite Variable  ${providerConsumerIdList}  

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${invoiceLabel}=   FakerLibrary.word
    ${invoiceDate}=   db.get_date_by_timezone  ${tz}
    ${amount}=   Random Int  min=500  max=2000
    ${amount}=     roundoff    ${amount}   1
    ${resp}=   Get next invoice Id   ${lid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${invoiceId}   ${resp.json()}


     ${SERVICE1}=    generate_unique_service_name  ${service_names}
    Set Suite Variable  ${SERVICE1}
    ${desc}=   FakerLibrary.sentence
    ${servicecharge}=   Random Int  min=100  max=500



    ${resp}=  Create Service  ${SERVICE1}  ${desc}   ${service_duration}  ${bool[0]}  ${servicecharge}  ${bool[1]}  
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sid1}  ${resp.json()} 

    ${quantity}=   Random Int  min=5  max=10
    ${quantity}=  Convert To Number  ${quantity}  1
        ${serviceprice}=   Random Int  min=10  max=15
    ${serviceprice}=  Convert To Number  ${serviceprice}  1

    ${serviceList}=  Create Dictionary  serviceId=${sid1}   quantity=${quantity}  price=${serviceprice}
    ${serviceList}=    Create List    ${serviceList}

     ${item1}=     FakerLibrary.word
    ${itemCode1}=     FakerLibrary.word
    ${price1}=     Random Int   min=400   max=500
    ${price}=  Convert To Number  ${price1}  1
    Set Suite Variable  ${price} 
    ${resp}=  Create Sample Item   ${DisplayName1}   ${item1}  ${itemCode1}  ${price}  ${bool[1]} 
    Log  ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${itemId}  ${resp.json()}

    ${resp}=   Get Item By Id  ${itemId}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${promotionalPrice}   ${resp.json()['promotionalPrice']}


    ${quantity}=   Random Int  min=500  max=1000
    ${quantity}=  Convert To Number  ${quantity}  1
    ${itemList}=  Create Dictionary  itemId=${itemId}   quantity=${quantity}  price=${promotionalPrice}
    
    
    ${resp}=  Create Invoice   ${category_id2}    ${invoiceDate}    ${invoiceId}    ${providerConsumerIdList}   ${lid}   ${itemList}  serviceList=${serviceList}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${invoice_uid}   ${resp.json()['uidList'][0]} 

    ${discount1}=     FakerLibrary.word
    ${desc}=   FakerLibrary.word
    ${discountprice1}=     Random Int   min=50   max=100
    ${discountprice}=  Convert To Number  ${discountprice1}  1
    Set Suite Variable   ${discountprice}
    ${resp}=   Create Discount  ${discount1}   ${desc}    ${discountprice}   ${calctype[1]}  ${disctype[0]}
    Log  ${resp.json()}
    Set Suite Variable   ${discountId}   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Discounts 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word
    ${discountValue1}=     Random Int   min=50   max=100
    ${discountValue1}=  Convert To Number  ${discountValue1}  1


    ${resp}=  Apply Item Level Discount   ${invoice_uid}   ${discountId}    ${discountValue1}   ${privateNote}  ${displayNote}   ${itemId}
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Invoice By Id  ${invoice_uid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.json()['itemList'][0]['discounts'][0]['id']}  ${discountId}
    # Should Be Equal As Strings  ${resp.json()['itemList'][0]['discounts'][0]['name']}  ${discount1}
    # Should Be Equal As Strings  ${resp.json()['itemList'][0]['discounts'][0]['discountType']}  ${disctype[0]}
    # Should Be Equal As Strings  ${resp.json()['itemList'][0]['discounts'][0]['discountValue']}  ${discountprice}
    # Should Be Equal As Strings  ${resp.json()['itemList'][0]['discounts'][0]['calculationType']}  ${calctype[1]}
    # Should Be Equal As Strings  ${resp.json()['itemList'][0]['discounts'][0]['privateNote']}  ${privateNote}
    # Should Be Equal As Strings  ${resp.json()['itemList'][0]['discounts'][0]['displayNote']}  ${displayNote}


JD-TC-Apply Item Level Discount-2

    [Documentation]  Apply item level discount where discount price is empty.


    ${resp}=   Encrypted Provider Login  ${PUSERPH30}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200


    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word

    ${discount1}=     FakerLibrary.word
    ${desc}=   FakerLibrary.word
    ${discountprice1}=     Random Int   min=50   max=100
    ${discountprice}=  Convert To Number  ${discountprice1}  1
    Set Suite Variable   ${discountprice}
    ${resp}=   Create Discount  ${discount1}   ${desc}    ${discountprice}   ${calctype[1]}  ${disctype[0]}
    Log  ${resp.json()}
    Set Test Variable   ${discountId}   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Discounts 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Apply Item Level Discount   ${invoice_uid}   ${discountId}    ${EMPTY}   ${privateNote}  ${displayNote}   ${itemId}
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Invoice By Id  ${invoice_uid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.json()['itemList'][0]['discounts'][1]['id']}  ${discountId}
    # Should Be Equal As Strings  ${resp.json()['itemList'][0]['discounts'][1]['name']}  ${discount1}
    # Should Be Equal As Strings  ${resp.json()['itemList'][0]['discounts'][1]['discountType']}  ${disctype[0]}
    # Should Be Equal As Strings  ${resp.json()['itemList'][0]['discounts'][1]['discountValue']}  ${discountprice}
    # Should Be Equal As Strings  ${resp.json()['itemList'][0]['discounts'][1]['calculationType']}  ${calctype[1]}
    # Should Be Equal As Strings  ${resp.json()['itemList'][0]['discounts'][1]['privateNote']}  ${privateNote}
    # Should Be Equal As Strings  ${resp.json()['itemList'][0]['discounts'][1]['displayNote']}  ${displayNote}

JD-TC-Apply Item Level Discount-3

    [Documentation]  Apply item level discount where private note  is empty.


    ${resp}=   Encrypted Provider Login  ${PUSERPH30}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word

    ${discount1}=     FakerLibrary.word
    ${desc}=   FakerLibrary.word
    ${discountprice1}=     Random Int   min=50   max=100
    ${discountprice}=  Convert To Number  ${discountprice1}  1
    Set Suite Variable   ${discountprice}
    ${resp}=   Create Discount  ${discount1}   ${desc}    ${discountprice}   ${calctype[1]}  ${disctype[0]}
    Log  ${resp.json()}
    Set Test Variable   ${discountId}   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Discounts 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Apply Item Level Discount   ${invoice_uid}   ${discountId}    ${EMPTY}   ${EMPTY}  ${displayNote}   ${itemId}
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Invoice By Id  ${invoice_uid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.json()['itemList'][0]['discounts'][2]['id']}  ${discountId}
    # Should Be Equal As Strings  ${resp.json()['itemList'][0]['discounts'][2]['name']}  ${discount1}
    # Should Be Equal As Strings  ${resp.json()['itemList'][0]['discounts'][2]['discountType']}  ${disctype[0]}
    # Should Be Equal As Strings  ${resp.json()['itemList'][0]['discounts'][2]['discountValue']}  ${discountprice}
    # Should Be Equal As Strings  ${resp.json()['itemList'][0]['discounts'][2]['calculationType']}  ${calctype[1]}
    # Should Be Equal As Strings  ${resp.json()['itemList'][0]['discounts'][2]['privateNote']}  ${EMPTY}
    # Should Be Equal As Strings  ${resp.json()['itemList'][0]['discounts'][2]['displayNote']}  ${displayNote}

JD-TC-Apply Item Level Discount-4

    [Documentation]  Apply item level discount where display note is empty.


    ${resp}=   Encrypted Provider Login  ${PUSERPH30}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

   ${discount1}=     FakerLibrary.word
    ${desc}=   FakerLibrary.word
    ${discountprice1}=     Random Int   min=50   max=100
    ${discountprice}=  Convert To Number  ${discountprice1}  1
    Set Suite Variable   ${discountprice}
    ${resp}=   Create Discount  ${discount1}   ${desc}    ${discountprice}   ${calctype[1]}  ${disctype[0]}
    Log  ${resp.json()}
    Set Test Variable   ${discountId}   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Discounts 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${privateNote}=     FakerLibrary.word


    ${resp}=  Apply Item Level Discount   ${invoice_uid}   ${discountId}    ${EMPTY}   ${privateNote}  ${EMPTY}   ${itemId}
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Invoice By Id  ${invoice_uid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.json()['itemList'][0]['discounts'][3]['id']}  ${discountId}
    # Should Be Equal As Strings  ${resp.json()['itemList'][0]['discounts'][3]['name']}  ${discount1}
    # Should Be Equal As Strings  ${resp.json()['itemList'][0]['discounts'][3]['discountType']}  ${disctype[0]}
    # Should Be Equal As Strings  ${resp.json()['itemList'][0]['discounts'][3]['discountValue']}  ${discountprice}
    # Should Be Equal As Strings  ${resp.json()['itemList'][0]['discounts'][3]['calculationType']}  ${calctype[1]}
    # Should Be Equal As Strings  ${resp.json()['itemList'][0]['discounts'][3]['privateNote']}  ${privateNote}
    # Should Be Equal As Strings  ${resp.json()['itemList'][0]['discounts'][3]['displayNote']}  ${EMPTY}

JD-TC-Apply Item Level Discount-5

    [Documentation]  Apply item level discount where private note and display note is empty.


    ${resp}=   Encrypted Provider Login  ${PUSERPH30}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${discount1}=     FakerLibrary.word
    ${desc}=   FakerLibrary.word
    ${discountprice1}=     Random Int   min=50   max=100
    ${discountprice}=  Convert To Number  ${discountprice1}  1
    Set Suite Variable   ${discountprice}
    ${resp}=   Create Discount  ${discount1}   ${desc}    ${discountprice}   ${calctype[1]}  ${disctype[0]}
    Log  ${resp.json()}
    Set Test Variable   ${discountId}   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Discounts 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200


    ${resp}=  Apply Item Level Discount   ${invoice_uid}   ${discountId}    ${EMPTY}   ${EMPTY}  ${EMPTY}   ${itemId}
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Invoice By Id  ${invoice_uid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.json()['itemList'][0]['discounts'][4]['id']}  ${discountId}
    # Should Be Equal As Strings  ${resp.json()['itemList'][0]['discounts'][4]['name']}  ${discount1}
    # Should Be Equal As Strings  ${resp.json()['itemList'][0]['discounts'][4]['discountType']}  ${disctype[0]}
    # Should Be Equal As Strings  ${resp.json()['itemList'][0]['discounts'][4]['discountValue']}  ${discountprice}
    # Should Be Equal As Strings  ${resp.json()['itemList'][0]['discounts'][4]['calculationType']}  ${calctype[1]}
    # Should Be Equal As Strings  ${resp.json()['itemList'][0]['discounts'][4]['privateNote']}  ${EMPTY}
    # Should Be Equal As Strings  ${resp.json()['itemList'][0]['discounts'][4]['displayNote']}  ${EMPTY}


JD-TC-Apply Item Level Discount-UH1

    [Documentation]   Apply Item  Level Discount(created discount value).


    ${resp}=   Encrypted Provider Login  ${PUSERPH30}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word


    ${resp}=   Apply Item Level Discount   ${invoice_uid}   ${discountId}    ${discountprice}   ${privateNote}  ${displayNote}  ${itemId}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${DISCOUNT_ALREADY_USED}

JD-TC-Apply Item Level Discount-UH3

    [Documentation]  Apply item level discount where Invoice uid is wrong.


    ${resp}=   Encrypted Provider Login  ${PUSERPH30}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word
    ${invoice}=   FakerLibrary.word


    ${resp}=   Apply Item Level Discount   ${invoice}   ${discountId}    ${discountprice}   ${privateNote}  ${displayNote}  ${itemId}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${INVALID_FM_INVOICE_ID}

JD-TC-Apply Item Level Discount-UH4

    [Documentation]  Apply item level discount where discount id is wrong.


    ${resp}=   Encrypted Provider Login  ${PUSERPH30}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word
    ${wrongdiscount}=   FakerLibrary.RandomNumber

    ${resp}=   Apply Item Level Discount   ${invoice_uid}   ${wrongdiscount}    ${discountprice}   ${privateNote}  ${displayNote}  ${itemId}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${INCORRECT_DISCOUNT_ID}
    # Should Be Equal As Strings  "${resp.json()}"  "${LOGIN_NO_ACCESS_FOR_URL}"

JD-TC-Apply Item Level Discount-UH5

    [Documentation]  Apply item level discount where Item id is wrong.


    ${resp}=   Encrypted Provider Login  ${PUSERPH30}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word
    ${item}=  FakerLibrary.RandomNumber


    ${resp}=   Apply Item Level Discount   ${invoice_uid}   ${discountId}    ${discountprice}   ${privateNote}  ${displayNote}  ${item}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${NO_ITEM_FOUND}

JD-TC-Apply Item Level Discount-UH6

    [Documentation]  Apply item level discount using another provider login.


    ${resp}=   Encrypted Provider Login  ${PUSERNAME134}  ${PASSWORD} 
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word


    ${resp}=   Apply Item Level Discount   ${invoice_uid}   ${discountId}    ${discountprice}   ${privateNote}  ${displayNote}  ${itemId}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}   ${INVALID_FM_INVOICE_ID}


JD-TC-Apply Item Level Discount-UH2

    [Documentation]  Create an invoice with itemlist and apply discount to invoice then try to apply same discount in item level.



    ${resp}=  Encrypted Provider Login  ${HLPUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

    ${decrypted_data}=  db.decrypt_data   ${resp.content}
    Log  ${decrypted_data}

    Set Suite Variable  ${pid}  ${decrypted_data['id']}
    Set Suite Variable    ${pdrname}    ${decrypted_data['userName']}
    Set Suite Variable    ${pdrfname}    ${decrypted_data['firstName']}
    Set Suite Variable    ${pdrlname}    ${decrypted_data['lastName']}
    
    ${resp}=  Get Business Profile
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${sub_domain_id}  ${resp.json()['serviceSubSector']['id']}
    Set Suite Variable  ${account_id1}  ${resp.json()['id']}

    ${resp}=  Get Waitlist Settings
    Log  ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    IF  ${resp.json()['filterByDept']}==${bool[0]}
        ${resp}=   Enable Disable Department  ${toggle[0]}
        Log  ${resp.content}
        Should Be Equal As Strings  ${resp.status_code}  200

    END
    

    ${dep_name1}=  FakerLibrary.bs
    ${dep_code1}=   Random Int  min=100   max=999
    ${dep_desc1}=   FakerLibrary.word  
    ${resp1}=  Create Department  ${dep_name1}  ${dep_code1}  ${dep_desc1} 
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Set Suite Variable  ${dep_id}  ${resp1.json()}



    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    
    IF  ${resp.json()['enableJaldeeFinance']}==${bool[0]}
        ${resp1}=    Enable Disable Jaldee Finance   ${toggle[0]}
        Log  ${resp1.content}
        Should Be Equal As Strings  ${resp1.status_code}  200
    END

    ${resp}=  Get jp finance settings
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['enableJaldeeFinance']}  ${bool[1]}

    ${resp}=  Create Sample Location  
    Set Suite Variable    ${lid}    ${resp}  

    ${resp}=   Get Location ById  ${lid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${tz}  ${resp.json()['timezone']}

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


    ${name1}=   FakerLibrary.word
    Set Suite Variable   ${name1}
    ${resp}=  Create Category   ${name1}  ${categoryType[3]} 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable   ${category_id2}   ${resp.json()}

    ${vender_name}=   FakerLibrary.firstname
    ${contactPersonName}=   FakerLibrary.lastname
    ${owner_name}=   FakerLibrary.lastname
    ${vendorId}=   FakerLibrary.word
    ${PO_Number}    Generate random string    5    123456789
    ${vendor_phno}=  Evaluate  ${PUSERNAME}+${PO_Number}
     ${vendor_phno}=  Create Dictionary  countryCode=${countryCodes[0]}   number=${vendor_phno}
    Set Test Variable  ${email}  ${vender_name}.${test_mail}
    ${address}=  FakerLibrary.city
    Set Suite Variable  ${address}
    ${bank_accno}=   db.Generate_random_value  size=11   chars=${digits} 
    ${branch}=   db.get_place
    ${ifsc_code}=   db.Generate_ifsc_code
    # ${gst_num}  ${pan_num}=   db.Generate_gst_number   ${Container_id}

    ${pin}  ${city}  ${district}  ${state}=  get_pin_loc

    ${state}=    Evaluate     "${state}".title()
    ${state}=    String.RemoveString  ${state}    ${SPACE}
    Set Suite Variable    ${state}
    Set Suite Variable    ${district}
    Set Suite Variable    ${pin}
    ${vendor_phno}=   Create List  ${vendor_phno}
    Set Suite Variable    ${vendor_phno}
    
    ${email}=   Create List  ${email}
    Set Suite Variable    ${email}

    ${bankIfsc}    Random Number 	digits=5 
    ${bankIfsc}=    Evaluate    f'{${bankIfsc}:0>7d}'
    Log  ${bankIfsc}
    Set Suite Variable  ${bankIfsc}  55555${bankIfsc} 

    ${bankName}     FakerLibrary.name
    Set Suite Variable    ${bankName}

    ${upiId}     FakerLibrary.name
    Set Suite Variable  ${upiId}

    ${pan}    Random Number 	digits=5 
    ${pan}=    Evaluate    f'{${pan}:0>5d}'
    Log  ${pan}
    Set Suite Variable  ${pan}  55555${pan}

    ${branchName}=    FakerLibrary.name
    Set Suite Variable  ${branchName}
    ${gstin}    Random Number 	digits=5 
    ${gstin}=    Evaluate    f'{${gstin}:0>8d}'
    Log  ${gstin}
    Set Test Variable  ${gstin}  55555${gstin}
    
    ${preferredPaymentMode}=    Create List    ${jaldeePaymentmode[0]}
    ${bankInfo}=    Create Dictionary     bankaccountNo=${bank_accno}    ifscCode=${bankIfsc}    bankName=${bankName}    upiId=${upiId}     branchName=${branchName}    pancardNo=${pan}    gstNumber=${gstin}    preferredPaymentMode=${preferredPaymentMode}    lastPaymentModeUsed=${jaldeePaymentmode[0]}
    ${bankInfo}=    Create List         ${bankInfo}
    


    ${resp1}=  AddCustomer  ${CUSERNAME11}
    Log  ${resp1.content}
    Should Be Equal As Strings  ${resp1.status_code}  200
    Set Test Variable  ${pcid18}   ${resp1.json()}


    ${providerConsumerIdList}=  Create List  ${pcid18}
    Set Test Variable  ${providerConsumerIdList}  

    ${referenceNo}=   Random Int  min=5  max=200
    ${referenceNo}=  Convert To String  ${referenceNo}

    ${description}=   FakerLibrary.word
    # Set Suite Variable  ${address}
    ${invoiceLabel}=   FakerLibrary.word
    ${invoiceDate}=   db.get_date_by_timezone  ${tz}

    ${resp}=   Get next invoice Id   ${lid}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${invoiceId}   ${resp.json()}


    ${itemName}=    FakerLibrary.word
    Set Test Variable  ${itemName}
     ${item1}=     FakerLibrary.word
    ${itemCode1}=     FakerLibrary.word
    ${price1}=     Random Int   min=400   max=500
    ${price}=  Convert To Number  ${price1}  1
    Set Test Variable  ${price} 
    ${resp}=  Create Sample Item   ${itemName}   ${item1}  ${itemCode1}  ${price}  ${bool[1]} 
    Log  ${resp.json()}  
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${itemId}  ${resp.json()}

    ${resp}=   Get Item By Id  ${itemId}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${promotionalPrice}   ${resp.json()['promotionalPrice']}


    ${quantity}=   Random Int  min=500  max=1000
    ${quantity}=  Convert To Number  ${quantity}  1
    ${itemList}=  Create Dictionary  itemId=${itemId}   quantity=${quantity}  price=${promotionalPrice}

    
    
    ${resp}=  Create Invoice   ${category_id2}    ${invoiceDate}     ${invoiceId}    ${providerConsumerIdList}   ${lid}   ${itemList}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable   ${invoice_uid}   ${resp.json()['uidList'][0]} 

    ${discount1}=     FakerLibrary.word
    ${desc}=   FakerLibrary.word
    ${discountprice1}=     Random Int   min=50   max=100
    ${discountprice}=  Convert To Number  ${discountprice1}  1
    Set Test Variable   ${discountprice}
    ${resp}=   Create Discount  ${discount1}   ${desc}    ${discountprice}   ${calctype[1]}  ${disctype[0]}
    Log  ${resp.json()}
    Set Test Variable   ${discountId}   ${resp.json()}   
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=   Get Discounts 
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${privateNote}=     FakerLibrary.word
    ${displayNote}=   FakerLibrary.word
    ${discountValue1}=     Random Int   min=50   max=100
    ${discountValue1}=  Convert To Number  ${discountValue1}  1

    ${resp}=   Apply Discount   ${invoice_uid}   ${discountId}    ${discountprice}   ${privateNote}  ${displayNote}
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  Get Invoice By Id  ${invoice_uid}
    Log  ${resp.content}
    Should Be Equal As Strings  ${resp.status_code}  200
    Should Be Equal As Strings  ${resp.json()['discounts'][0]['id']}  ${discountId}
    # Should Be Equal As Strings  ${resp.json()['discounts'][0]['name']}  ${discount1}
    # Should Be Equal As Strings  ${resp.json()['discounts'][0]['discountType']}  ${disctype[0]}
    # Should Be Equal As Strings  ${resp.json()['discounts'][0]['discountValue']}  ${discountprice}
    # Should Be Equal As Strings  ${resp.json()['discounts'][0]['calculationType']}  ${calctype[1]}
    # Should Be Equal As Strings  ${resp.json()['discounts'][0]['privateNote']}  ${privateNote}
    # Should Be Equal As Strings  ${resp.json()['discounts'][0]['displayNote']}  ${displayNote}


    ${resp}=  Apply Item Level Discount   ${invoice_uid}   ${discountId}    ${EMPTY}   ${privateNote}  ${displayNote}   ${itemId}
    Log  ${resp.json()} 
    Should Be Equal As Strings  ${resp.status_code}  200







