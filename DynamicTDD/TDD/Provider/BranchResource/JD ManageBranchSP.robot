*** Settings ***
Suite Teardown  Delete All Sessions
Test Teardown   Delete All Sessions
Force Tags      Branch
Library         Collections
Library         String
Library         json
Library         FakerLibrary
Library         /ebs/TDD/db.py
Resource        /ebs/TDD/ProviderKeywords.robot
Resource        /ebs/TDD/ProviderKeywordsforBranchSP.robot
Resource        /ebs/TDD/ConsumerKeywords.robot
Variables       /ebs/TDD/varfiles/providers.py
Variables       /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***
${SERVICE1}   SERVICE1
${SERVICE2}   SERVICE2

*** Test Cases ***

JD-TC-ManageBranchSP-1
	[Documentation]    Create location, service, queue and check in for branch SPs by passing tab_id through header.

	${domresp}=  ProviderKeywords.Get BusinessDomainsConf
    Should Be Equal As Strings  ${domresp.status_code}  200

*** Comment ***

    ${dlen}=  Get Length  ${domresp.json()}
    FOR  ${pos}  IN RANGE  ${dlen}  
        Set Suite Variable  ${domain}  ${domresp.json()[${pos}]['domain']}

        ${subdomain}  ${subdomain_id}=  Get Corporate Subdomain  ${domain}  ${domresp}  ${pos}  
        Set Suite Variable   ${subdomain}
        Exit For Loop IF    '${subdomain}'

    END
    
    ${firstname}=  FakerLibrary.name
    ${lastname}=  FakerLibrary.last_name
    ${PUSERNAME_Z}=  Evaluate  ${PUSERNAME}+8830   
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERNAME_Z}${\n}
    ${pkg_id}=   get_highest_license_pkg
    ${resp}=  ProviderKeywords.Account SignUp  ${firstname}  ${lastname}  ${None}  ${domain}  ${subdomain}  ${PUSERNAME_Z}   ${pkg_id[0]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  ProviderKeywords.Account Activation  ${PUSERNAME_Z}  0
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  ProviderKeywords.Account Set Credential  ${PUSERNAME_Z}  ${PASSWORD}  0
    Should Be Equal As Strings    ${resp.status_code}    200
    Set Suite Variable  ${PUSERNAME_Z}
    ${resp}=  ProviderKeywords.Provider Login  ${PUSERNAME_Z}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${corp_name}=   FakerLibrary.word
    Set Suite Variable  ${corp_name}
    ${corp_code}=   FakerLibrary.word
    Set Suite Variable  ${corp_code}
    ${resp}=  ProviderKeywordsforBranchSP.Switch To Corporate  ${corp_name}  ${corp_code}  ${bool[1]}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 
	Set Suite Variable  ${branch_id}  ${resp.json()}

	${f_name}=  	 FakerLibrary.first_name
    ${l_name}=  	 FakerLibrary.last_name
	${email}=   	 Set Variable  ${P_Email}${PUSERNAME_Z}.${test_mail}
    ${PHONE11}=  Evaluate  ${PUSERNAME}+77520 
    Set Suite Variable   ${PHONE11}
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PHONE11}${\n}
	${resp}=   ProviderKeywordsforBranchSP.Create Branch SP  ${f_name}  ${l_name}   ${PHONE11}   ${email}  ${subdomain}  ${PASSWORD}
	Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 
	Set Suite Variable  ${sp_id1}  ${resp.json()} 

	${resp}=   ProviderKeywordsforBranchSP.Manage Branch SP   ${sp_id1}
	Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
	Set Suite Variable  ${tab_id1}  ${resp.json()['tabId']} 

    ${PUSERPH1}=  Evaluate  ${PUSERNAME}+342
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERPH1}${\n}

    ${PUSERPH2}=  Evaluate  ${PUSERNAME}+343
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PUSERPH2}${\n}

    ${PUSERMAIL0}=   Set Variable  ${P_Email}${PUSERNAME_Z}.${test_mail}
    ${views}=  Evaluate  random.choice($Views)  random
    Log   ${views}
    ${DAY1}=  db.get_date_by_timezone  ${tz}
    Set Suite Variable   ${DAY1}
    ${list}=  Create List   1  2  3  4  5  6  7
    Set Suite Variable    ${list}
    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  ProviderKeywordsforBranchSP.Phone Numbers  ${name1}  PhoneNo  ${PUSERPH1}  ${views}
    ${ph_nos2}=  ProviderKeywordsforBranchSP.Phone Numbers  ${name2}  PhoneNo  ${PUSERPH2}  ${views}
    ${emails1}=  ProviderKeywordsforBranchSP.Emails  ${name3}  Email  ${PUSERMAIL0}  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${sTime}=  db.subtract_timezone_time  ${tz}  3  25
    ${eTime}=  add_timezone_time  ${tz}  0  30   
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ['True','False']
    ${resp}=  ProviderKeywordsforBranchSP.Create Business Profile  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${tab_id1}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

	${city1}=   get_place
    ${latti1}=  get_latitude
    ${longi1}=  get_longitude
    ${postcode1}=  FakerLibrary.postcode
    ${address1}=  get_address
    ${parking1}    Random Element     ${parkingType} 
    ${24hours1}    Random Element    ['True','False']
    ${list1}=  Create List  1  2  3  4  5  
    # ${sTime1}=  db.get_time_by_timezone   ${tz}
    ${sTime1}=  db.get_time_by_timezone  ${tz}
    ${eTime1}=  add_timezone_time  ${tz}  0  15  
    ${url1}=   FakerLibrary.url
    ${resp}=  ProviderKeywordsforBranchSP.Create Location  ${city1}  ${longi1}  ${latti1}  ${url1}  ${postcode1}  ${address1}  ${parking1}  ${24hours1}  ${recurringtype[1]}  ${list1}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime1}  ${eTime1}  ${tab_id1}
    Log  ${resp.json()}    
    Log  ${resp.headers}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${loc_id1}  ${resp.json()}

	${f_name}=  	 FakerLibrary.first_name
    ${l_name}=  	 FakerLibrary.last_name
	${PHONE1}=  Evaluate  ${PUSERNAME}+7744 
    Set Suite Variable   ${PHONE1}
    Append To File  ${EXECDIR}/TDD/TDD_Logs/numbers.txt  ${PHONE1}${\n}
	${email}=   	 Set Variable  ${P_Email}${PHONE1}.${test_mail}
    
	${resp}=   ProviderKeywordsforBranchSP.Create Branch SP  ${f_name}  ${l_name}   ${PHONE1}   ${email}  ${subdomain}  ${PASSWORD}
	Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 
	Set Suite Variable  ${sp_id2}  ${resp.json()} 

	${resp}=  ProviderKeywordsforBranchSP.Manage Branch SP   ${sp_id2}
	Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200
	Set Suite Variable  ${tab_id2}  ${resp.json()['tabId']} 

    ${name1}=  FakerLibrary.name
    ${name2}=  FakerLibrary.name
    ${name3}=  FakerLibrary.name
    ${ph_nos1}=  ProviderKeywordsforBranchSP.Phone Numbers  ${name1}  PhoneNo  ${PUSERPH1}  ${views}
    ${ph_nos2}=  ProviderKeywordsforBranchSP.Phone Numbers  ${name2}  PhoneNo  ${PUSERPH2}  ${views}
    ${emails1}=  ProviderKeywordsforBranchSP.Emails  ${name3}  Email  ${PUSERMAIL0}  ${views}
    ${bs}=  FakerLibrary.bs
    ${companySuffix}=  FakerLibrary.companySuffix
    # ${city}=   FakerLibrary.state
    # ${latti}=  get_latitude
    # ${longi}=  get_longitude
    # ${postcode}=  FakerLibrary.postcode
    # ${address}=  get_address
    ${latti}  ${longi}  ${postcode}  ${city}  ${district}  ${state}  ${address}=  get_loc_details
    ${sTime}=  db.subtract_timezone_time  ${tz}  3  25
    ${eTime}=  add_timezone_time  ${tz}  0  30   
    ${desc}=   FakerLibrary.sentence
    ${url}=   FakerLibrary.url
    ${parking}   Random Element   ${parkingType}
    ${24hours}    Random Element    ['True','False']
    ${resp}=  ProviderKeywordsforBranchSP.Create Business Profile  ${bs}  ${desc}   ${companySuffix}  ${city}   ${longi}  ${latti}  ${url}  ${parking}  ${bool[1]}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  ${postcode}  ${address}  ${ph_nos1}  ${ph_nos2}  ${emails1}  ${tab_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200

	${city2}=   get_place
    ${latti2}=  get_latitude
    ${longi2}=  get_longitude
    ${postcode2}=  FakerLibrary.postcode
    ${address2}=  get_address
    ${parking2}    Random Element     ${parkingType} 
    ${24hours2}    Random Element    ['True','False']
    ${DAY2}=  db.add_timezone_date  ${tz}   2
    ${list2}=  Create List  1  2  3  4  5  6  7
    ${sTime2}=  add_timezone_time  ${tz}  1  00  
    ${eTime2}=  add_timezone_time  ${tz}  2  15  
    ${url2}=   FakerLibrary.url
    ${resp}=  ProviderKeywordsforBranchSP.Create Location  ${city2}  ${longi2}  ${latti2}  ${url2}  ${postcode2}  ${address2}  ${parking2}  ${24hours2}  ${recurringtype[1]}  ${list2}  ${DAY2}  ${EMPTY}  ${EMPTY}  ${sTime2}  ${eTime2}  ${tab_id2}
    Log  ${resp.json()}
    Log  ${resp.headers}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${loc_id2}  ${resp.json()}

	${resp}=  ProviderKeywordsforBranchSP.Get Location ById  ${loc_id1}   ${tab_id1}
	Log  ${resp.json()}
	Should Be Equal As Strings  ${resp.status_code}  200
	Verify Response  ${resp}  place=${city1}  longitude=${longi1}  lattitude=${latti1}  pinCode=${postcode1}  address=${address1}  parkingType=${parking1}  open24hours=${24hours1}  googleMapUrl=${url1}  status=${status[0]}
	Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['recurringType']}  		 ${recurringtype[1]}
	Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['repeatIntervals']}  		 ${list1}
   	Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['startDate']}  			 ${DAY1}
	Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${sTime1}
	Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${eTime1}

	${resp}=  ProviderKeywordsforBranchSP.Get Location ById  ${loc_id2}   ${tab_id2}
	Log  ${resp.json()}
	Should Be Equal As Strings  ${resp.status_code}  200
	Verify Response  ${resp}  place=${city2}  longitude=${longi2}  lattitude=${latti2}  pinCode=${postcode2}  address=${address2}  parkingType=${parking2}  open24hours=${24hours2}  googleMapUrl=${url2}  status=${status[0]}
	Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['recurringType']}  		 ${recurringtype[1]}
	Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['repeatIntervals']}  		 ${list2}
   	Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['startDate']}  			 ${DAY2}
	Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['timeSlots'][0]['sTime']}  ${sTime2}
	Should Be Equal As Strings  ${resp.json()['bSchedule']['timespec'][0]['timeSlots'][0]['eTime']}  ${eTime2}

	${resp}=  ProviderKeywordsforBranchSP.Get Location ById  ${loc_id1}   ${tab_id2}
	Log  ${resp.json()}
	Should Be Equal As Strings  ${resp.status_code}  401

    ${desc1}=   FakerLibrary.sentence
    ${servicecharge1}=   FakerLibrary.pyfloat   left_digits=3   right_digits=2   positive=True
    ${ser_durtn1}=   Random Int   min=2   max=10
    ${resp}=  ProviderKeywordsforBranchSP.Create Service  ${SERVICE1}  ${desc1}   ${ser_durtn1}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge1}  ${bool[0]}  ${bool[0]}   ${tab_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sid1}  ${resp.json()}

    ${desc2}=   FakerLibrary.sentence
    ${servicecharge2}=   FakerLibrary.pyfloat   left_digits=3   right_digits=2   positive=True
    ${ser_durtn2}=   Random Int   min=2   max=10
    ${resp}=  ProviderKeywordsforBranchSP.Create Service  ${SERVICE2}  ${desc2}   ${ser_durtn2}  ${status[0]}    ${btype}    ${bool[1]}  ${notifytype[2]}   ${EMPTY}  ${servicecharge2}  ${bool[0]}  ${bool[0]}   ${tab_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${sid2}  ${resp.json()}

    ${resp}=   ProviderKeywordsforBranchSP.Get Service By Id  ${sid1}   ${tab_id1}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${SERVICE1}  description=${desc1}  serviceDuration=${ser_durtn1}   notification=${bool[1]}   notificationType=${notifytype[2]}  totalAmount=${servicecharge1}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]} 
    
    ${resp}=   ProviderKeywordsforBranchSP.Get Service By Id  ${sid2}   ${tab_id2}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  name=${SERVICE2}  description=${desc2}  serviceDuration=${ser_durtn2}   notification=${bool[1]}   notificationType=${notifytype[2]}  totalAmount=${servicecharge2}  status=${status[0]}  bType=${btype}  isPrePayment=${bool[0]} 
    
    ${resp}=   ProviderKeywordsforBranchSP.Get Service By Id  ${sid1}   ${tab_id2}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  401

    ${cons_id}=  get_id  ${CUSERNAME1}     
    Set Suite Variable  ${cons_id} 

    ${q_name}=    FakerLibrary.name
    Set Suite Variable    ${q_name}
    ${strt_time}=   add_timezone_time  ${tz}  1  00  
    Set Suite Variable    ${strt_time}
    ${end_time}=    add_timezone_time  ${tz}  3  00   
    Set Suite Variable    ${end_time}   
    ${parallel}=   Random Int  min=1   max=1
    Set Suite Variable   ${parallel}
    ${capacity}=  Random Int   min=10   max=20
    Set Suite Variable   ${capacity}
    ${resp}=  ProviderKeywordsforBranchSP.Create Queue    ${q_name}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time}  ${end_time}  ${parallel}   ${capacity}  ${loc_id1}  ${tab_id1}  ${sid1}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id1}   ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  ProviderKeywordsforBranchSP.Add To Waitlist  ${cons_id}  ${sid1}  ${que_id1}  ${DAY1}  ${desc}  ${bool[1]}  ${tab_id1}  ${cons_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${wid}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid}  ${wid[0]}
    ${resp}=  ProviderKeywordsforBranchSP.Get Waitlist By Id  ${wid}  ${tab_id1}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1  appxWaitingTime=0  waitlistedBy=PROVIDER   personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE1}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${sid1}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['id']}   ${cons_id}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cons_id}

    ${q_name1}=    FakerLibrary.name
    Set Suite Variable    ${q_name1}
    ${strt_time1}=   add_timezone_time  ${tz}  2  00  
    Set Suite Variable    ${strt_time1}
    ${end_time1}=    add_timezone_time  ${tz}  4  00   
    Set Suite Variable    ${end_time1}   
    ${resp}=  ProviderKeywordsforBranchSP.Create Queue    ${q_name1}  ${recurringtype[1]}  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${strt_time1}  ${end_time1}  ${parallel}   ${capacity}  ${loc_id2}  ${tab_id2}  ${sid2}  
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Suite Variable  ${que_id2}   ${resp.json()}

    ${desc}=   FakerLibrary.word
    ${resp}=  ProviderKeywordsforBranchSP.Add To Waitlist  ${cons_id}  ${sid2}  ${que_id2}  ${DAY1}  ${desc}  ${bool[1]}  ${tab_id2}  ${cons_id}
    Log   ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    
    ${wid1}=  Get Dictionary Values  ${resp.json()}
    Set Test Variable  ${wid1}  ${wid1[0]}
    ${resp}=  ProviderKeywordsforBranchSP.Get Waitlist By Id  ${wid1}  ${tab_id2}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    Verify Response  ${resp}  date=${DAY1}  waitlistStatus=${wl_status[1]}  partySize=1  appxWaitingTime=0  waitlistedBy=PROVIDER   personsAhead=0
    Should Be Equal As Strings  ${resp.json()['service']['name']}                 ${SERVICE2}
    Should Be Equal As Strings  ${resp.json()['service']['id']}                   ${sid2}
    Should Be Equal As Strings  ${resp.json()['consumer']['userProfile']['id']}   ${cons_id}
    Should Be Equal As Strings  ${resp.json()['waitlistingFor'][0]['id']}         ${cons_id}

JD-TC-ManageBranchSP-2
	[Documentation]    Get location by Independent login of SPs.

    ${resp}=  ProviderKeywordsforBranchSP.Provider Login  ${PHONE11}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=  ProviderKeywords.Get Location ById  ${loc_id1}  
	Log  ${resp.json()}
	Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderKeywords.Get Location ById  ${loc_id2}  
	Log  ${resp.json()}
	Should Be Equal As Strings  ${resp.status_code}  401

    ${resp}=  ProviderKeywordsforBranchSP.Provider Login  ${PHONE1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    200 

    ${resp}=  ProviderKeywords.Get Location ById  ${loc_id2}  
	Log  ${resp.json()}
	Should Be Equal As Strings  ${resp.status_code}  200

    ${resp}=  ProviderKeywords.Get Location ById  ${loc_id1}  
	Log  ${resp.json()}
	Should Be Equal As Strings  ${resp.status_code}  401
    
***Keywords***

Get Corporate Subdomain
    [Arguments]   ${domain}  ${jsondata}  ${posval}  
    ${length}=  Get Length  ${jsondata.json()[${posval}]['subDomains']}
    FOR  ${pos}  IN RANGE  ${length}
            Set Test Variable  ${subdomain}  ${jsondata.json()[${posval}]['subDomains'][${pos}]['subDomain']}
            Set Test Variable  ${subdomain_id}  ${jsondata.json()[${posval}]['subDomains'][${pos}]['id']}
            ${resp}=   ProviderKeywords.Get Sub Domain Settings    ${domain}    ${subdomain}
            Should Be Equal As Strings    ${resp.status_code}    200
            Exit For Loop IF  '${resp.json()['isCorp']}' == '${bool[1]}'
    END
    RETURN  ${subdomain}   ${subdomain_id}

Get Non-Corporate Subdomain
    [Arguments]   ${domain}  ${jsondata}  ${posval}  
    ${length}=  Get Length  ${jsondata.json()[${posval}]['subDomains']}
    FOR  ${pos}  IN RANGE  ${length}
            Set Test Variable  ${subdomain}  ${jsondata.json()[${posval}]['subDomains'][${pos}]['subDomain']}
            ${resp}=   ProviderKeywords.Get Sub Domain Settings    ${domain}    ${subdomain}
            Should Be Equal As Strings    ${resp.status_code}    200
            Exit For Loop IF  '${resp.json()['isCorp']}' == '${bool[0]}'
    END
    RETURN  ${subdomain}  
