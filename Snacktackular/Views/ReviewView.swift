//
//  ReviewView.swift
//  Snacktackular
//
//  Created by Jeremy Taylor on 2/4/23.
//

import SwiftUI
import Firebase

struct ReviewView: View {
    @StateObject var reviewVM = ReviewViewModel()
    @State var spot: Spot
    @State var review: Review
    @State var postedByThisUser = false
    @State var rateOrReviewerString = "Click to Rate:"
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text(spot.name)
                    .font(.title)
                    .bold()
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
                Text(spot.address)
                    .padding(.bottom)
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(rateOrReviewerString)
                .font(postedByThisUser ? .title2 : .subheadline)
                .bold(postedByThisUser)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .padding(.horizontal)
            HStack {
                StarsSelectionView(rating: $review.rating)
                    .disabled(!postedByThisUser) // disable if not posted by this user
                    .overlay {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.gray.opacity(0.5), lineWidth: postedByThisUser ? 2 : 0)
                    }
            }
            .padding(.bottom)
            
            VStack(alignment: .leading) {
                Text("Review Title:")
                    .bold()
                
                TextField("title", text: $review.title)
                    .padding(.horizontal, 6)
                    .overlay {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.gray.opacity(0.5), lineWidth: postedByThisUser ? 2 : 0.3)
                    }
                
                Text("Review")
                    .bold()
                
                TextField("Review", text: $review.body, axis: .vertical)
                    .padding(.horizontal, 6)
                    .frame(maxHeight: .infinity, alignment: .topLeading)
                    .overlay {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.gray.opacity(0.5), lineWidth: postedByThisUser ? 2 : 0.3)
                    }
            }
            .disabled(!postedByThisUser)
            .padding(.horizontal)
            .font(.title2)
            
            
            Spacer()
        }
        .onAppear {
            if review.reviewer == Auth.auth().currentUser?.email {
                postedByThisUser = true
            } else {
                let reviewPostedOn = review.postedOn.formatted(date: .numeric, time: .omitted )
                rateOrReviewerString = "by: \(review.reviewer) on: \(reviewPostedOn)"
            }
        }
        .navigationBarBackButtonHidden(postedByThisUser) // Hide back button if posted by this user
        .toolbar {
            if postedByThisUser {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            let success = await reviewVM.saveReview(spot: spot, review: review)
                            if success {
                                dismiss()
                            } else {
                                print("😡 ERROR saving data in ReviewView")
                            }
                        }
                    }
                }
            }
        }
    }
}

struct ReviewView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ReviewView(spot: Spot(name: "Shake Shack", address: "49 Boyleston St., Chestnut Hill, MA 02467"), review: Review())
        }
    }
}
