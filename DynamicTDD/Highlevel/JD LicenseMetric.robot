*** Settings ***
Suite Teardown    Delete All Sessions
Test Teardown     Delete All Sessions
Force Tags        License
Library           Collections
Library           String
Library           json
Library           FakerLibrary
Resource          /ebs/TDD/ProviderKeywords.robot
Resource          /ebs/TDD/ConsumerKeywords.robot
Variables         /ebs/TDD/varfiles/providers.py
Variables         /ebs/TDD/varfiles/consumerlist.py 

*** Variables ***
${DAY1}            2015-06-14
${DAY2}            2019-04-01
${ph1}             1895590090
${ph2}             1020567630
${ph3}             1895590091
${ph4}             1020567631
${ph5}             1895590092
${ph6}             1020567632
${ph7}             1894490092
${ph8}             1021667632
${ph9}             1894490093
${ph10}            1021667633


${sTime}           06:00 AM
${eTime}	       11:00 PM
${longi}           89.524764
${latti}           45.259874
${longi1}           10.524764
${latti1}           80.259874
${longi2}           32.524764
${latti2}           40.259874
${longi3}           50.524764
${latti3}           60.259874
${longi4}           40.524764
${latti4}           10.259874

${PUSERNAME}     1111111121
${PUSERNAME1}    1111111122
${PUSERNAME2}    1111111123
${PUSERNAME3}    1111111124
${PUSERNAME4}    1111111125


*** Test Cases ***

YNW-TC-License Metric-1
    Comment    Basic Package - gallery limit

    Comment  Gallery limit set to 1MB IN licenseconfig.json 
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
*** Comment ***
    Set Test Variable  ${d1}  ${resp.json()[0]['domain']}
    Set Test Variable  ${sd1}  ${resp.json()[0]['subDomains'][0]['subDomain']}
    ${resp}=  Account SignUp  biju  x  ${None}  ${d1}  ${sd1}  ${PUSERNAME}    1
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Provider Login  ${PUSERNAME}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${DAY1}=  get_date
    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph_nos1}=  Phone Numbers  Doctor  Phoneno  ${ph1}  self
    ${ph_nos2}=  Phone Numbers  Receptionist  Phoneno  ${ph2}  all
    ${emails1}=  Emails  Doctor  Email  ${EMPTY}  customersOnly
    ${resp}=  Create Business Profile  manju Health Care  kattappana   manju  iddukki  ${longi}  ${latti}  www.sampleurl.com  free  True  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  680020  Puliparambil House  ${ph_nos1}  ${ph_nos2}  ${emails1}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200      
    ${resp}=  uploadGalleryImageFile   ${cookie}  TDD/large.jpeg
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  uploadGalleryImageFile   ${cookie}  TDD/small.jpg
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  You are not allowed to do operation because it exceeds limit. You can upgrade license package/addon for more benefits
    ${resp}=   Get GalleryOrlogo image  gallery
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Test Variable   ${name}  ${resp.json()[0]['keyName']}   
    ${resp}=  DeleteProviderGalleryImage  ${name}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

YNW-TC-License Metric-2
    Comment    Silver-- gallery limit
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${d2}  ${resp.json()[1]['domain']}
    Set Test Variable  ${sd2}  ${resp.json()[1]['subDomains'][0]['subDomain']}
    ${resp}=  Account SignUp  Arjun  nv  ${None}  ${d2}  ${sd2}  ${PUSERNAME1}    2
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME1}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200   
    ${resp}=  Provider Login  ${PUSERNAME1}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${DAY1}=  get_date
    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph_nos1}=  Phone Numbers  Beautician  Phoneno  ${ph3}  self
    ${ph_nos2}=  Phone Numbers  Receptionist  Phoneno  ${ph4}  all
    ${emails1}=  Emails  Beautician  Email  ${EMPTY}  customersOnly
    ${resp}=  Create Business Profile  Devi personal care  mndy   Devi  mndy  ${longi1}  ${latti1}  www.sampleurl.com  free  True  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  680010  Thadathil House  ${ph_nos1}  ${ph_nos2}  ${emails1}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200      
    ${resp}=  uploadGalleryImageFile   ${cookie}  TDD/large.jpeg
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  uploadGalleryImageFile   ${cookie}  TDD/small.jpg
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  You are not allowed to do operation because it exceeds limit. You can upgrade license package/addon for more benefits
    ${resp}=   Get GalleryOrlogo image  gallery
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Test Variable   ${name}  ${resp.json()[0]['keyName']}   
    ${resp}=  DeleteProviderGalleryImage  ${name}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

YNW-TC-License Metric-3
    Comment    Gold - gallery limit
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${d3}  ${resp.json()[2]['domain']}
    Set Test Variable  ${sd3}  ${resp.json()[2]['subDomains'][0]['subDomain']}
    ${resp}=  Account SignUp  jain  nv  ${None}  ${d3}  ${sd3}  ${PUSERNAME2}    3
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME2}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Provider Login  ${PUSERNAME2}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${DAY1}=  get_date
    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph_nos1}=  Phone Numbers  Manager  Phoneno  ${ph5}  self
    ${ph_nos2}=  Phone Numbers  Receptionist  Phoneno  ${ph6}  all
    ${emails1}=  Emails  Manager  Email  ${EMPTY}  all
    ${resp}=  Create Business Profile  Devi Health Care  Edathala   Devi  palakkad  ${longi2}  ${latti2}  www.sampleurl.com  free  True  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  680030  Palliyil House  ${ph_nos1}  ${ph_nos2}  ${emails1}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200      
    ${resp}=  uploadGalleryImageFile   ${cookie}  TDD/large.jpeg
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  uploadGalleryImageFile   ${cookie}  TDD/small.jpg
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  You are not allowed to do operation because it exceeds limit. You can upgrade license package/addon for more benefits
    ${resp}=   Get GalleryOrlogo image  gallery
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Test Variable   ${name}  ${resp.json()[0]['keyName']}   
    ${resp}=  DeleteProviderGalleryImage  ${name}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

YNW-TC-License Metric-4
    Comment    Diamond - gallery limit
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${d4}  ${resp.json()[3]['domain']}
    Set Test Variable  ${sd4}  ${resp.json()[3]['subDomains'][0]['subDomain']}
    ${resp}=  Account SignUp  simmy  nv  ${None}  ${d4}  ${sd4}  ${PUSERNAME3}    4
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME3}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME3}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Provider Login  ${PUSERNAME3}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${DAY1}=  get_date
    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph_nos1}=  Phone Numbers  Manager  Phoneno  ${ph7}  self
    ${ph_nos2}=  Phone Numbers  Receptionist  Phoneno  ${ph8}  all
    ${emails1}=  Emails  Manager  Email  ${EMPTY}  all
    ${resp}=  Create Business Profile  Devi Health Care  ernakaulam   Devi  ernakulam  ${longi2}  ${latti2}  www.sampleurl.com  free  True  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  680040  udhayooth House  ${ph_nos1}  ${ph_nos2}  ${emails1}
    Should Be Equal As Strings    ${resp.status_code}    200 
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200      
    ${resp}=  uploadGalleryImageFile   ${cookie}  TDD/large.jpeg
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  uploadGalleryImageFile   ${cookie}  TDD/small.jpg
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  You are not allowed to do operation because it exceeds limit. You can upgrade license package/addon for more benefits
    ${resp}=   Get GalleryOrlogo image  gallery
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Test Variable   ${name}  ${resp.json()[0]['keyName']}   
    # ${resp}=  DeleteProviderGalleryImage  ${name}
    ${resp}=  Imageupload.deleteGalleryImg  ${name}  ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

YNW-TC-License Metric-5
    Comment    Gold-trial - gallery limit
    ${resp}=  Get BusinessDomainsConf
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${d5}  ${resp.json()[4]['domain']}
    Set Test Variable  ${sd5}  ${resp.json()[4]['subDomains'][0]['subDomain']}
    ${resp}=  Account SignUp  piston  nv  ${None}  ${d5}  ${sd5}  ${PUSERNAME4}   5
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Activation  ${PUSERNAME4}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Account Set Credential  ${PUSERNAME4}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${resp}=  Provider Login  ${PUSERNAME4}  ${PASSWORD}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${DAY1}=  get_date
    ${list}=  Create List  1  2  3  4  5  6  7
    ${ph_nos1}=  Phone Numbers  Manager  Phoneno  ${ph9}  self
    ${ph_nos2}=  Phone Numbers  Receptionist  Phoneno  ${ph10}  all
    ${emails1}=  Emails  Manager  Email  ${EMPTY}  all
    ${resp}=  Create Business Profile  Devi Health Care  TVM   Devi  TVM  ${longi2}  ${latti2}  www.sampleurl.com  free  True  Weekly  ${list}  ${DAY1}  ${EMPTY}  ${EMPTY}  ${sTime}  ${eTime}  680050  sopanam House  ${ph_nos1}  ${ph_nos2}  ${emails1}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME4}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200      
    ${resp}=  uploadGalleryImageFile   ${cookie}  TDD/large.jpeg
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200
    ${resp}=  uploadGalleryImageFile   ${cookie}  TDD/small.jpg
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  You are not allowed to do operation because it exceeds limit. You can upgrade license package/addon for more benefits
    ${resp}=   Get GalleryOrlogo image  gallery
    Should Be Equal As Strings  ${resp.status_code}  200 
    Set Test Variable   ${name}  ${resp.json()[0]['keyName']}   
    # ${resp}=  DeleteProviderGalleryImage  ${name}
    ${resp}=  Imageupload.deleteGalleryImg  ${name}  ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200

YNW-TC-License Metric-6
    Comment  Basic - gallery limit (multiple images in same request)
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    ${resp}=  uploadGalleryImageMultiple    ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  You are not allowed to do operation because it exceeds limit. You can upgrade license package/addon for more benefits

YNW-TC-License Metric-7
    Comment  Silevr - gallery limit (multiple images in same request)
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME1}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    ${resp}=  uploadGalleryImageMultiple    ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  You are not allowed to do operation because it exceeds limit. You can upgrade license package/addon for more benefits

YNW-TC-License Metric-8
    Comment  Gold - gallery limit (multiple images in same request)
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME2}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    ${resp}=  uploadGalleryImageMultiple    ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  You are not allowed to do operation because it exceeds limit. You can upgrade license package/addon for more benefits

YNW-TC-License Metric-9
    Comment  Diamond - gallery limit (multiple images in same request)
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME3}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    ${resp}=  uploadGalleryImageMultiple    ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  You are not allowed to do operation because it exceeds limit. You can upgrade license package/addon for more benefits

YNW-TC-License Metric-10
    Comment  Gold Trial - gallery limit (multiple images in same request)
    ${cookie}  ${resp}=   Imageupload.spLogin  ${PUSERNAME4}  ${PASSWORD}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  200  
    ${resp}=  uploadGalleryImageMultiple    ${cookie}
    Log  ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}  422
    Should Be Equal As Strings  ${resp.json()}  You are not allowed to do operation because it exceeds limit. You can upgrade license package/addon for more benefits




*** Comment ***
${resp}=   Get Service
    Should Be Equal As Strings  ${resp.status_code}  200  
    Set Test Variable  ${sid}  ${resp.json()[0]['id']} 
    ${resp}=  Get queues
    Should Be Equal As Strings  ${resp.status_code}  200
    Set Test Variable  ${qid}  ${resp.json()[0]['id']}

    ${cid}=  get_id  ${CUSERNAME}
    ${resp}=  Add To Waitlist  ${cid}  ${sid}  ${qid}  ${DAY1}  hi  True  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid}=  get_id  ${CUSERNAME1}
    ${resp}=  Add To Waitlist  ${cid}  ${sid}  ${qid}  ${DAY1}  hi  True  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid}=  get_id  ${CUSERNAME2}
    ${resp}=  Add To Waitlist  ${cid}  ${sid}  ${qid}  ${DAY1}  hi  True  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid}=  get_id  ${CUSERNAME3}
    ${resp}=  Add To Waitlist  ${cid}  ${sid}  ${qid}  ${DAY1}  hi  True  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200

    ${cid}=  get_id  ${CUSERNAME4}
    ${resp}=  Add To Waitlist  ${cid}  ${sid}  ${qid}  ${DAY1}  hi  True  ${cid}
    Should Be Equal As Strings  ${resp.status_code}  200
    