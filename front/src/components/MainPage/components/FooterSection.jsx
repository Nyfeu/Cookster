import './FooterSection.css'

const FooterSection = () => {
    return (
        <footer class="px-5 custom-footer">
            <div class="d-flex flex-column align-items-center text-center gap-2 flex-sm-row justify-content-between py-1 my-3">
                <p class="mb-0">&copy; 2025 Cookster, Inc. All rights reserved.</p>
                <ul class="list-unstyled d-flex gap-4 mb-0 mt-3 mt-sm-0">
                    <li class="ms-3"><a class="text-white" href="#"><i class="fab fa-facebook-f fa-lg"></i></a></li>
                    <li class="ms-3"><a class="text-white" href="#"><i class="fab fa-twitter fa-lg"></i></a></li>
                    <li class="ms-3"><a class="text-white" href="#"><i class="fab fa-google fa-lg"></i></a></li>
                    <li class="ms-3"><a class="text-white" href="#"><i class="fab fa-linkedin fa-lg"></i></a></li>
                </ul>
            </div>
        </footer>
    )
}

export default FooterSection