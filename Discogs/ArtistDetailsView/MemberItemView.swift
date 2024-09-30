//
//  MemberItemView.swift
//  Discogs
//
//  Created by Omar Torres on 9/29/24.
//

import SwiftUI

struct MemberItemView: View {
	private let member: Member
	
	init(_ member: Member) {
		self.member = member
	}
	
    var body: some View {
		HStack {
			if let url = URL(string: member.thumbnailUrl) {
				AsyncImage(url: url) { image in
					image
						.resizable()
						.aspectRatio(contentMode: .fit)
						.frame(width: 50, height: 50)
						.clipped()
				} placeholder: {
					ProgressView()
						.frame(width: 50, height: 50)
				}
			}
			Text("\(member.name)")
		}
    }
}

#Preview {
	MemberItemView(.dummyMember)
}
