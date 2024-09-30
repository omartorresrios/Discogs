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
		ScrollView {
			ForEach(members, id: \.id) { member in
				Text("\(member.name)")
			}
		}
    }
}

#Preview {
	MembersView(members: [.dummyMember])
}
