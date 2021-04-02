//
//  LoadingStatus.swift
//  CtaReactiveMaster
//
//  Created by 化田晃平 on R 3/03/06.
//

enum LoadingStatus {
    case initial
    case loading
    case loadSuccess
    case loadFailed(Error)
}

