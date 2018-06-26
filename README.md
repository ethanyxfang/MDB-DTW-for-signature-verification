# MDB-DTW-for-signature-verification
The code of "A Novel Multiple Distances Based Dynamic Time Warping Method for Online Signature Verification"

## MDB-DTW
- Paper Link: 

- Title: A Novel Multiple Distances Based Dynamic Time Warping Method for Online Signature Verification

- Author: Xinyi Lu, Yuxun Fang, Qiuxia Wu, Junhong Zhao, Wenxiong Kang (from BIP Lab, SCUT, P.R.China)

- Date: 2018/05/20

- Contact: fang.yuxun@mail.scut.edu.cn

- COPYRIGHT (C) Xinyi Lu, Yuxun Fang, Qiuxia Wu, Junhong Zhao, Wenxiong Kang

- ALL RIGHTS RESERVED

  The code can be used only for academic researches, when use this code in your paper, please cite the paper.

  __[1] X. Lu, Y. Fang, Q. Wu, J. Zhao, W. Kang, A Novel Multiple Distances Based Dynamic Time Warping Method for Online Signature Verification, Chinese Conference on Biometric Recognition, 2018.__

  __[2] L. Tang, W. Kang, Y. Fang, Information Divergence-based Matching Strategy for Online Signature Verification, IEEE Transactions on Information Forensics & Security, 2018.13(4): 861-873.__

## Instructions
​    Because of the permissions, we can't provide the database. You need to add the susig, mcyt and svc2004 database to the folder.

​    Run the "main.m" script in MATLAB.

​    You can select the initialization parameters in __setting__.

## Performance
__Note__: We only report the results when using 10 reference samples here. For more detail please refer to the paper.

 database  | SVM   | PCA   
 --------- | ----- | ----- 
 mcyt      | 1.84% | 1.87% 
 susig     | 1.38% | 1.28% 
 svc task2 | 6.26% | 6.32% 
