import SwiftUI

struct CustomButton: View {
    let title: String
    let backgroundColor: Color
    
    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(backgroundColor)
            )
    }
}

#Preview {
    CustomButton(
        title: "Giriş Yap",
        backgroundColor: .green
    )
    .padding()
} 