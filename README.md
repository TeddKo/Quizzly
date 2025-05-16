# Quizzly

## _SwiftUI 기반 반응형 퀴즈 앱_
> 나만의 문제를 만들고, 풀고, 복습하세요.  
>                

</br>  
</br>  

<p float="left">
  <img src="https://github.com/user-attachments/assets/5e13e8f3-06a7-4ad9-b235-4ce25c5c7d7c" width="170" />
  <img src="https://github.com/user-attachments/assets/9a6042e7-ed9a-421f-9d61-ec2911457b38" width="170" /> 
  <img src="https://github.com/user-attachments/assets/b33e902a-038e-475a-8ad9-50a97c03236c" width="170" />
  <img src="https://github.com/user-attachments/assets/e04f76a7-7df0-40d6-a4c6-81402109b068" width="170" />
  <img src="https://github.com/user-attachments/assets/fef61f4e-a238-41c8-8e13-52247f83b875" width="170" />
</p>

</br>   

## Description
  * 퀴즈 컨텐츠 관리
    * 사용자가 직접 카테고리를 생성 및 관리
    * 사용자가 직접 퀴즈(질문 + 보기)를 생성 및 관리
  * 반응형 학습 제공
    * 카테고리 / 난이도 별로 퀴즈 필터링된 퀴즈 풀이
    * 퀴즈 결과 요약, 정답률, 오답노트가 담긴 통계 대시보드 제공
   
</br>

## 유즈케이스
사용자는 프로필로 로그인 한 다음 카테고리를 정하여 문제와 보기 난이도를 가지고 문제를 출제하거나 카테고리별로 풀 수 있습니다.
사용자의 카테고리안 질문들은 세션으로 구성되며 세션 마지막에는 질문의 총 갯수와 맞은 갯수 경과시간을 알려줍니다.

</br>

## Navigation Stack

```
- ChooseProfileView  ← 루트: 프로필 선택

    └── MainTabView  ← BottomBar 탭 구조
        ├── HomeView (탭 1: 홈 화면)
        │     └── QuizView (카테고리 선택 시 퀴즈 시작)
        │         └── QuizResultView (퀴즈 종료 후 결과 화면)         

        ├── AddQuizView (탭 2: 퀴즈 생성)

        └── DashboardView (탭 3: 오답노트 + 통계)
```
</br>   

## Requirements
* iOS 17.0+     

</br>   

## Tech Stack
* Swift
* SwiftUI
* SwiftData
* MVVM         
