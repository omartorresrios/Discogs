//
//  MembersView.swift
//  Discogs
//
//  Created by Omar Torres on 9/29/24.
//

import SwiftUI

struct MembersView: View {
	private let members: [Member]
	
	init(members: [Member]) {
		self.members = members
	}
	
    var body: some View {
		VStack(spacing: 5) {
			Text("Members")
				.font(.title2)
				.padding()
			ScrollView {
				ForEach(members, id: \.id) { member in
					MemberItemView(member)
						.frame(maxWidth: .infinity, alignment: .leading)
				}
			}
		}
		.padding(.horizontal)
		.background(.green)
    }
}

#Preview {
	MembersView(members: [.dummyMember, .dummyMember])
}
