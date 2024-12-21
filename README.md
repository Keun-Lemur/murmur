# Murmur, 머머: 심장동물병원찾기 서비스

## Download Available January 2025

![Murmur Logo](https://github.com/user-attachments/assets/dbfce7e0-9b88-4080-b394-d9e35fffe061)

- **iOS**: [Download on the App Store](https://apps.apple.com/kr/app/ë¨¸¸iOS: [https://apps.apple.com/kr/app/ë¨¸\xb8ë¨¨iOS: [https://apps.apple.com/kr/app/ë¨¸\xb8ë¨\xa8¸¨iOS: [https://apps.apple.com/kr/app/ë¨¸\xb8ë¨\xa8¸\xa8¸iOS: https://apps.apple.com/kr/app/ë¨¸\xb8ë¨\xa8¸\xa8\xb8/id6702028834?l=en-GB)
- **Android**: [Download on Google Play](https://play.google.com/store/apps/details?id=com.concrete.JaegaebalNew)

## Tech Stack

- **Django**
  - Chosen for its simplicity and usability, ideal for a small startup team.
  - Provides well-structured backend APIs, allowing for efficient development.
  - Uses the MVT (Model-View-Template) software architecture to implement core features like album categorization, vet searches, and reviews.

- **Database**
  - PostgreSQL is used to ensure scalability as the service expands to other veterinary departments.

- **CI/CD Pipeline**
  - Integrated using Railway for automated deployments, enabling rapid builds and releases for each code update.

- **Flutter**
  - Enables simultaneous development for iOS, Android, and web platforms.
  - Built using the MVVP (Model-View-ViewModel-Pattern) architecture, ensuring clear data flow and easier debugging.
  - Ideal for rapid development due to prior experience with Flutter in media apps.

- **Firebase**
  - Used for user authentication across both web and app platforms, ensuring a seamless login experience.
  - **Key Integration**: Addressed issues with KakaoTalk login API differences between web and app platforms by implementing conditional logic in the Flutter code.
  - **Challenge**: Flutter’s web optimization limitations caused delays in integrating the KakaoTalk API, but Firebase was used as the primary authentication system to overcome these challenges and ensure reliable functionality.

## Overview

Murmur is inspired by the sound of a heart murmur, symbolizing our mission to assist pets suffering from heart conditions like:

- Mitral Valve Disease (MVD)
- Hypertrophic Cardiomyopathy (HCM)
- Congestive Heart Failure (CHF)

In South Korea, pet owners face high veterinary costs compared to human healthcare due to the lack of pet health insurance. This issue becomes more pressing as pets age and are diagnosed with conditions such as MVD, HCM, or CHF. Compounding this problem is the absence of a formal veterinary specialist certification system in Korea, making it difficult for pet owners to assess the quality of care provided by veterinarians.

Murmur was created to address this gap by helping pet owners find trusted and experienced vets specializing in heart diseases for elderly pets. Starting with heart-related specialties, the platform aims to expand its focus to other areas, including neurology, ophthalmology, and orthopedics.

## Key Features

- **Search for Top Veterinarians**: Locate reputable vets specializing in heart conditions within the Seoul metropolitan area.
- **Curated Vet Albums**: Access groups of veterinarians categorized by similar treatment styles and specialties.
- **Transparent Reviews**: Read honest and critical comments about veterinarians from other pet owners.
- **Vet Profiles**: Check detailed vet records, including prescription methods, diagnostic tools, and post-appointment availability for inquiries.

## Goals

- Support pet owners of elderly pets with heart conditions by providing reliable vet information in the Seoul metropolitan area.
- Begin with heart disease specialization and gradually expand to other medical departments.

## Team Achievements

- **DAU Growth**: Reached 16,000 Daily Active Users (DAU) during the MVP stage.
- **User Research**: Engaged with 1,000 pet owners through cafe communities and major animal medical centers in Seoul and Bucheon to refine the service.
- **Lessons Learned**: Despite initial growth, the team pivoted due to challenges in identifying a sustainable business model.

## Key Troubleshooting

### KakaoTalk API Integration

- **Problem**: KakaoTalk login API behaved differently between app and web platforms, leading to inconsistencies in functionality.
- **Solution**: Implemented conditional logic within the Flutter code to handle platform-specific API behaviors.
- **Challenge**: Flutter’s web optimization limitations caused delays in making the KakaoTalk API work seamlessly.
- **Outcome**: Firebase authentication was used as the primary system to provide a unified and reliable login experience across all platforms.

## Why Murmur?

Our mission is to empower pet owners with the resources and knowledge needed to care for their aging pets. With Murmur, we aim to build a trusted platform that alleviates the stress of navigating veterinary care, helping pets and their owners lead healthier, happier lives.

